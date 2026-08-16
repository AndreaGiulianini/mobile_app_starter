# Architecture

This document explains **why** the project is shaped the way it is. The README
covers setup and commands; this covers the decisions.

It is written for someone about to extend the app: each section states the rule,
then the reason, then what breaks if you ignore it.

---

## Layers

```
Widget  ──dispatch──▶  Bloc / Cubit  ──▶  Repository  ──▶  ClientAPI  ──▶  PokeAPI
   ▲                        │
   └────── State ───────────┘
```

Each layer only knows the one below it.

| Layer | Knows about | Never knows about |
|---|---|---|
| Widgets | Blocs, states, l10n | Dio, URLs, JSON |
| Blocs / Cubits | Repository, domain models | HTTP verbs, status codes, endpoints |
| Repository | `ClientAPI`, domain models | Widgets, `BuildContext` |
| `ClientAPI` | Dio | Blocs, widgets, `AppConfig` |

**Why the repository exists.** Without it, blocs end up holding transport
details, and any logic shared by two blocs gets duplicated into both. Two things
here make that concrete:

- `getPage` fans a page of names out into parallel detail requests — the list
  endpoint returns names and URLs only, so every entry needs a second call. The
  fan-out is **bounded** (6 in flight, not 20: public APIs rate-limit) and
  backed by an in-memory `Map<int, Pokemon>` cache, so scrolling back, searching
  for something already on screen, or opening a detail page never refetches a
  payload the app has seen. PokeAPI data is immutable, so entries never go stale.
- `searchByName` caches the full name index. PokeAPI has **no search endpoint** —
  `/pokemon/pikachu` resolves only on an exact name and 404s on anything
  partial. The repository fetches the whole index once (~1350 entries, ~90 KB),
  filters in memory, and hydrates only the matches. `SearchBloc` asks for
  "Pokémon matching `pika`" and never learns any of this. The cache holds the
  **future**, not the value, so concurrent searches share one request; a failure
  resets it so a transient error is not cached forever. The 1350-object parse
  runs off the UI isolate (`compute`), because it happens on the first
  keystroke — the worst possible moment to jank.
- Every method accepts an optional `CancelToken`. Cancelling a *handler* does
  not stop the HTTP work it started; the token is what reaches the transport.
  The repository re-exports `CancelToken` — the one re-export in the app, and
  it exists to enforce this table: blocs pass a token without importing dio.

**What breaks if you skip it.** Put an API call in a widget and it becomes
untestable without a network stub, and unreusable from a second screen.

Note what `ClientAPI` does *not* know: the base URL and the timeouts live in
the `BaseOptions` of the `Dio` it is handed (see [DI](#dependency-injection)),
so it never reads `AppConfig`. A client that configures the connection it was
given would be configuring a dependency it does not own.

---

## One tap, end to end

Tapping a card in the grid and landing on a populated detail page crosses every
layer in the table above. Follow it once and the rest of this document is
mostly footnotes.

```
PokemonCard.onTap
 └─▶ PokemonDetailPage(id:).go(context)      router/routes.dart
      └─▶ PokemonDetailScreen(id:)           screens/pokemon_detail_screen/
           └─▶ BlocProvider ── creates ──▶ PokemonDetailCubit
                └─▶ load()                   cubit/pokemon_detail_cubit.dart
                     └─▶ PokemonRepository.getById()   ← cache checked here
                          └─▶ ClientAPI.request() ──▶ Dio ──▶ PokeAPI
                                        │
        BlocBuilder ◀── PokemonDetailLoaded ◀┘
```

**1 · The tap.** `PokemonCard` (`screens/pokedex_screen/widgets/pokemon_card.dart`)
puts an `InkWell` over the card's whole content, and its `onTap` is one line:

```dart
onTap: () => PokemonDetailPage(id: pokemon.pokemonId).go(context),
```

No path string, no `Navigator.push`, no arguments map: the id is a constructor
parameter of a route class, and `.go()` comes from the generated
`$PokemonDetailPage` mixin. `go` rather than `push`, because the detail is a
route *nested* under `/` — this is a declarative move to `/pokemon/25`, and
back returns to the list with no extra handling.

**2 · The route builds the page.** `routes.dart` declares
`TypedGoRoute<PokemonDetailPage>(path: 'pokemon/:id')` and `go_router_builder`
generates the parsing, so `state.pathParameters['id']` never appears in app
code. `PokemonDetailPage.build` returns `PokemonDetailScreen(id: id)`, and the
`MaterialPageRouteData` mixin wraps it in a `MaterialPage` — [without which
every transition in the app silently disappears](#materialpageroutedata--read-this-before-adding-a-route).

**3 · The screen creates its own cubit.** `PokemonDetailScreen.build` is a
`BlocProvider` that pulls the repository out of the tree:

```dart
create: (context) => PokemonDetailCubit(context.read<PokemonRepository>(), id),
```

The only bloc built outside `main.dart`, deliberately: the provider owns it, so
it is created on push and closed on pop — one visit, one instance, no leftover
state from the previously viewed Pokémon. It reads the repository rather than
`getIt`, which is what keeps the screen constructible in a widget test.

**4 · The view asks for the data.** `_PokemonDetailView` is a `StatefulWidget`
whose `initState` schedules `context.read<PokemonDetailCubit>().load()` in a
post-frame callback, guarded by `mounted`. The view owns the trigger, not the
cubit's constructor: a fetch started in the constructor can neither be awaited
nor stubbed, and a synchronous throw from it lands in the middle of `build`.

**5 · The cubit runs the command.** `load()` cancels any previous token, makes
a fresh `CancelToken`, and emits `PokemonDetailLoading` before awaiting. On the
first run that emit equals the initial state, so Equatable dedupes it and no
rebuild happens; on a retry from `PokemonDetailFailure` it is what swaps the
error view back to the spinner.

**6 · The repository answers, often without the network.** `getById` checks
`_detailCache` first. In practice a card you can *see* has already been through
this method — the grid's `_withDetails` hydrated it through the same
`getById` — so tapping a visible Pokémon is normally a cache hit, no request is
made at all, and `PokemonDetailLoaded` lands on the next frame. A miss falls
through to the client and the result is cached on the way back.

**7 · The client talks to Dio.** `getPokemonById` builds
`Request(url: '/pokemon/$id', method: HttpMethod.get, cancelToken: …)`. The URL
is relative: it resolves against `BaseOptions.baseUrl` from the DI setup.
`ClientAPI.request` runs it, and anything that goes wrong is translated by
`_handleDioException` into the [`AppException` hierarchy](#errors) — the bloc
layer never sees a `DioException` or a status code.

**8 · The state comes back up.** `safeEmit(PokemonDetailLoaded(pokemon))`
(no-op if the route was already popped) reaches the
`BlocBuilder<PokemonDetailCubit, PokemonDetailState>` in `_PokemonDetailView`,
whose exhaustive `switch` swaps the spinner for `_LoadedView`. The artwork
carries the same `Hero` tag as the card (`pokemon-image-<id>`), so it flies
between the two routes rather than popping into place.

Worth noticing on that last screen: the `FavoriteButton` in the app bar talks to
`FavoritesBloc`, which is app-scoped and persisted, while everything else on the
page belongs to a cubit that dies with the route. Two lifetimes, one screen,
neither aware of the other.

### When it fails

The `try` in `load()` has three arms, and they are not interchangeable:

| Caught | Emits | Rendered as |
|---|---|---|
| `RequestCancelledException` | nothing | nothing — see below |
| `AppException` | `PokemonDetailFailure(e.message)` | the server's message + a Retry button |
| anything else | `PokemonDetailFailure()` (no message) | the localized `detailLoadFailed` |

Retry calls the same `load()`, which is why step 5 re-emits `Loading`.

### When the user leaves first

Popping the route closes the cubit, and `close()` cancels the token. Dio aborts
the request, `ClientAPI` maps the abort to `RequestCancelledException`, and the
cubit swallows it: cancellation is flow control, not a failure, so no error UI
is ever shown for a page the user already left. `safeEmit` is the second line of
defence — it drops any emit that arrives after close.

---

## Bloc or Cubit?

The app uses both on purpose, and the split is the point.

| | Used for | Why |
|---|---|---|
| `PokemonCubit` | Paginated list | Inputs are plain commands (`loadPokemon`, `loadMore`). No *stream* of inputs to transform, so events would be pure ceremony. |
| `PokemonDetailCubit` | One Pokémon | Same, and scoped to the route rather than the app. It does cancel its request on close — but with a `CancelToken`, which needs no event plumbing. |
| `SearchBloc` | Search-as-you-type | Needs an `EventTransformer`. **A cubit has no seam between "input arrives" and "handler runs"**, so debouncing would have to be hand-rolled in the widget with timers. |
| `FavoritesBloc` | Favourites | Toggling is an *event* the UI reports, not a command with a computed result — and events show up in `BlocObserver.onEvent`. Also `HydratedBloc`, so persistence is free. |

**Rule of thumb:** reach for a `Bloc` when you need to *transform the stream of
inputs* — debounce, throttle, drop, restart. Otherwise a `Cubit` says the same
thing with less machinery.

### The search transformer

`SearchBloc` routes **all** of its events through one handler and one
transformer, and every piece is load-bearing:

```dart
EventTransformer<SearchEvent> _searchTransformer(Duration duration) {
  return (Stream<SearchEvent> events, EventMapper<SearchEvent> mapper) {
    final Stream<SearchEvent> debouncedQueries =
        events.debounce(duration).whereType<SearchQueryChanged>();
    final Stream<SearchEvent> immediateClears =
        events.whereType<SearchCleared>();
    return restartable<SearchEvent>()(
      debouncedQueries.merge(immediateClears), mapper);
  };
}
```

- **`debounce`** drops keystrokes: typing `pikachu` issues one request, not seven.
- **`restartable()`** cancels a handler still in flight when a newer event
  arrives. Without it a slow request for `pika` can resolve *after* one for
  `pikachu` and overwrite the fresher results.
- **One `on<SearchEvent>`, not one per event type.** With separate
  registrations each event type gets its *own* transformed stream, so a
  `SearchCleared` could neither cancel an in-flight query nor evict one still
  sitting in the debounce window — stale results reappeared on a cleared field.
- **Every event feeds the debounce timer, but only queries come out of it.**
  A clear resetting that timer is what evicts a pending query, since debounce
  keeps only the last event it saw; filtering the branch to queries means the
  clear is *handled* once, from the undebounced branch, which is what makes
  the reset instant.
- **Cancellation reaches the transport.** `restartable` only cancels the
  handler; the bloc also cancels a per-query `CancelToken`, otherwise every
  superseded keystroke's 1 + 20 HTTP requests keep running to completion.

Each behaviour has a test that fails without it; the `restartable` one fails
with `Expected: 'pikachu' Actual: 'pika'` — literally that bug.

> A generation counter like `PokemonCubit`'s does **not** substitute for this.
> A query still inside the debounce window starts *after* the clear, so it
> captures a newer generation and the counter cannot reject it. Evicting it
> from the window is the only thing that works.

---

## State design

### Sealed states, exhaustive switches

State hierarchies are `sealed`, and the UI switches over them with no `default`:

```dart
return switch (state) {
  PokemonInitial() || PokemonLoading() => AppLoadingView(message: ...),
  PokemonError(:final String message)  => AppErrorView.withRetry(...),
  PokemonSuccess(:final List<Pokemon> pokemonList) => PokemonGrid(...),
  PokemonLoadingMore(:final List<Pokemon> currentList) => PokemonGrid(...),
};
```

Add a state and every incomplete switch becomes a **compile error** instead of a
silently blank screen. This is what the `exhaustive_cases` lint is reaching for,
and it is why `if (state is X)` chains are not used.

### All state lives in the state

No **view state** lives in a field. Pagination bookkeeping — the next offset,
whether more pages exist, whether one is in flight — is carried by
`PokemonSuccess` and `PokemonLoadingMore`. The only mutable fields anywhere in
the blocs are command plumbing that nothing renders: `_generation` and the
`_requestToken`s (see below).

This is not stylistic. Keeping part of the state machine outside the state
machine is the classic BLoC mistake, and it has a concrete cost:

> Before this was fixed, `PokemonCubit` kept `_currentOffset` as a private
> field. `blocTest(seed:)` sets the state but obviously cannot set a private
> field, so a seeded cubit silently re-requested page 0 — and the test passed
> anyway. The bug was invisible precisely because the state looked right.

A second payoff: the concurrency guard disappears. `loadMore` only acts on
`PokemonSuccess`, so calling it while `PokemonLoadingMore` is current is a no-op
**by construction**. No `_isLoadingMore` flag needed.

Two deliberate exceptions, both command plumbing rather than view state —
nothing rendered depends on either, so neither belongs in the state objects:

- **`PokemonCubit._generation`**, an `int` bumped at the start of every
  command. The state check above guards `loadMore`-vs-`loadMore`, but not
  `loadPokemon`-vs-`loadMore` — a reload started mid-append used to be
  overwritten by the stale append when it resolved late.
- **`_requestToken`** in `PokemonDetailCubit` and `SearchBloc`, cancelled on
  close and on supersession. Cancelling a handler does not stop the HTTP work
  it started; only the token reaches the transport.

Emitted collections are **unmodifiable** (`List.unmodifiable`,
`Set.unmodifiable`). A stray `state.pokemonList.add(...)` would otherwise
mutate state in place *and* keep Equatable equality, silently skipping the
rebuild.

**Rule:** if you cannot reconstruct the bloc's behaviour from `state` alone,
something belongs in the state that is not there.

---

## Widgets, not build methods

Anything that returns a `Widget` is a `Widget` class, never a `_buildX()`
method on a State. Methods cannot be `const`, rebuild whenever their host
rebuilds regardless of whether their inputs changed, and are invisible in the
widget inspector.

`lib/widgets/` holds everything used by more than one screen. Screen-private
widgets stay under that screen's folder — `search_field.dart` is only ever the
Pokédex app bar, so it lives there.

| Widget | Notes |
|---|---|
| `AppLoadingView` / `AppErrorView` / `AppEmptyView` | The three states every async screen has |
| `AppLoadingMoreIndicator` | Foot of a paginated list |
| `PokemonGrid` | Shared by the paginated list and search results |
| `PokemonTypeChip` | `.small()` for the card, `.large()` for detail |
| `AbilityChip`, `StatBar`, `LabelledValueRow`, `SectionTitle` | Detail-screen building blocks |
| `FavoriteButton` | Used by both the card and the detail app bar |

Two API choices worth copying:

- **Named constructors over a `size` enum.** `PokemonTypeChip.small()` /
  `.large()` set private final fields in their initialiser lists, so every
  variant stays `const`.
- **Named constructors over nullable pairs.** `AppErrorView` vs
  `AppErrorView.withRetry` makes "a retry button with no label" and "a label
  with no callback" unrepresentable, instead of two nullable parameters that
  have to agree.

> **A reusable widget must not change shape with its parent.** `PokemonTypeChip`
> first used `Container(alignment: ...)`, which makes a Container expand to fill
> its constraints. The chip stayed compact inside the card's unbounded row and
> stretched full-width inside the detail screen's `Wrap`. It now uses
> `Center(widthFactor: 1)`, and a test asserts it hugs its label under bounded
> constraints.

The card's type row is the other half of that story: it clips with
`ClipRect` + `OverflowBox` rather than wrapping or scrolling, because the card
gives types a fixed-height slot. It exposes `PokemonTypeChip.smallHeight` so
the row and the chip cannot drift apart. A horizontal `ListView` did the job
too, but put a whole `Scrollable` per card into the gesture arena.

---

## Choosing a bloc widget

| Widget | Use when | Used here for |
|---|---|---|
| `BlocBuilder` | The state *is* what you render | The grid, the detail body |
| `BlocSelector` | The state changes more often than your slice of it | `FavoriteButton` |
| `BlocListener` | The state is a one-off notification, not something to render | Search failures and failed `loadMore`s → SnackBar |

`FavoriteButton` is the interesting one. `FavoritesState` changes whenever *any*
Pokémon is toggled, so a `BlocBuilder` would rebuild every visible card on every
tap. `BlocSelector` narrows the state to one `bool`, and bloc skips the rebuild
when that bool is unchanged — so tapping one heart rebuilds one button. Visible
in DevTools' *Track widget rebuilds*.

Search failure uses `BlocListener` for the mirror-image reason: rendering it
with a builder would either replace the grid with an error page or need a flag
to dismiss it again. A failure is an event, not a screen.

---

## Dependency injection

Two mechanisms, with different jobs:

- **`get_it`** (`lib/core/di/service_locator.dart`) composes the object graph at
  startup. It is the only place that knows how a `PokemonRepository` is built.
- **`RepositoryProvider` / `BlocProvider`** put those objects into the widget
  tree so screens can reach them via `context.read`.

Widgets never call `getIt` directly — only `main.dart` does. That is what lets
`PokemonDetailScreen` build its own cubit from `context.read<PokemonRepository>()`
and stay constructible in a test without touching the locator.

Lifetimes are chosen, not defaulted:

| Registration | Why |
|---|---|
| `Dio`, `ClientAPI` — lazy singleton | Stateless; one connection pool. `Dio` is configured at registration (base URL, timeouts, debug interceptor): an owner must not mutate a dependency it was handed. |
| `PokemonRepository` — lazy singleton | It caches the name index and the detail payloads. A factory would refetch ~90 KB per search. |
| `PokemonCubit`, `SearchBloc` — factory | One per screen; disposed with it. |
| `FavoritesBloc` — lazy singleton | Favourites must be consistent across every screen showing a heart. |
| `PokemonDetailCubit` — not registered | Created inside the route's `BlocProvider`, so its lifetime matches the route: built on push, disposed on pop. |

**Ownership rule for providers.** `BlocProvider(create:)` takes ownership and
*closes* the bloc when the provider unmounts — correct for the factories, wrong
for the singletons: get_it would keep handing out the closed instance and the
next `add()` would throw. Singletons therefore go through `.value` providers,
and their `dispose:` callbacks in get_it (`bloc.close()`, `dio.close()`) make
`resetServiceLocator()` a real teardown.

---

## Routing

`go_router` with **typed routes** generated by `go_router_builder`. No path
string is ever assembled by hand:

```dart
PokemonDetailPage(id: pokemon.pokemonId).go(context);
```

Change `path: 'pokemon/:id'` and every call site fails to compile.

### `MaterialPageRouteData` — read this before adding a route

Every typed route **must** mix in `MaterialPageRouteData`.

go_router picks its page builder by calling
`findAncestorWidgetOfExactType<MaterialApp>()` against the *legacy*
`package:flutter/material` type. Since the app moved to `package:material_ui`
that lookup fails, so go_router falls back to `NoTransitionPage` for every
route — silently. No error, no log, just no page transitions anywhere.

`MaterialUiCompatibilityBridge` does not help: it bridges inherited-widget
lookups like `Theme.of`, not lookups by exact ancestor type.

`test/router/routes_test.dart` asserts every route in `$appRoutes` builds a
`MaterialPage`, and was confirmed to fail without the mixin. Remove the mixin
when go_router ships `material_ui` support — nothing in its changelog through
17.5.0 mentions it yet.

---

## Errors

`ClientAPI._handleDioException` maps `DioException` onto the app's own
`AppException` hierarchy. The switch is **exhaustive with no `default:`**, on
purpose:

> Dart 3 offers no way to have both "exhaustive today" and "silently tolerant of
> future enum values": a trailing `return` leaves the switch non-exhaustive, and
> a `default:` becomes unreachable once every case is covered. Failing the build
> is the better half. When dio 5.11 added `transformTimeout`, the compiler
> pointed at the exact line and inspection showed it is a *timeout* — a
> `default:` would have bucketed it into `UnknownException` and degraded the
> user-facing message with nothing to signal it.

Names and shape worth knowing:

- The timeout case maps to **`RequestTimeoutException`**, not `TimeoutException`
  — that name would shadow `dart:async`'s and make `on TimeoutException` catch
  the wrong type wherever both are imported.
- **`RequestCancelledException`** is flow control, not failure: blocs catch it
  and return, so a cancelled request never renders as an error.
- **`ParsingException`** covers "the response is not the JSON object the parser
  expects" (proxy error pages, empty bodies) — previously a bare `TypeError`
  from an unchecked cast, which escaped the hierarchy entirely.
- Every mapped *failure* carries the originating `DioException` as `cause` (and
  its `stackTrace`), so a crash reporter still sees the request context.
  `RequestCancelledException` is the exception: there is no failure to report.
  Equality compares only `message` and `statusCode`.

Only `message` is positional; `cause`, `stackTrace` and `statusCode` are named
on every subclass. They used to be positional, which put `statusCode` in slot 2
for `ServerException` and `cause` in slot 2 for everything else — two
constructions four lines apart in `client.dart` meaning different things.
The types tied to a single code (401, 404, 400) state it as a `statusCode`
override rather than a constructor argument: a `NotFoundException` *is* a 404,
it does not merely happen to carry one.

`AppException.message` is **not localized**. That layer has no `BuildContext`,
and doing it properly means turning `message` into an error *code* and mapping
code → string at the widget layer. That is the right refactor and a separate
one; until then these read as English developer defaults. Where the bloc has
no server-provided message at all it emits `null`, and the widget layer
substitutes the localized generic string (`searchFailed`, `detailLoadFailed`).

---

## Localization

Flutter's built-in `gen_l10n`, no third-party package.

- Strings live in `lib/l10n/app_<locale>.arb`. `app_en.arb` is the template and
  every resource in it needs an `@`-description.
- Adding `app_<locale>.arb` is all it takes — `supportedLocales` is derived from
  the filenames.
- Generation runs on `pub get` / `run` / `build`, but **not** on `analyze`,
  which is why the generated Dart is committed. Otherwise a fresh clone is a
  wall of red in the IDE.
- Use `AppLocalizations.localizationsDelegates`, never a hand-written list: the
  generated one already bundles the Material, Widgets and Cupertino globals, so
  it stays correct as those delegates move between packages.

---

## Testing

94 tests. `bloc_test` + `mocktail`, no code generation.

### Two mocking seams

**Blocs and cubits** mock `PokemonRepository`. That is the layer boundary, so
the tests describe behaviour rather than transport.

**Repository and client** mock `ClientAPI.request` — *not* `getListPokemon` or
`getPokemonById`. Those two are **extension methods**, so they are dispatched
statically and mocktail cannot intercept them at all: stubbing them silently
does nothing and the real body runs anyway. Stubbing the request underneath is
both the only option and the better one, because URL building and DTO parsing
then get exercised for real.

### Widget tests

`test/helpers/pump_app.dart` mounts the four providers every screen expects,
plus localization with the locale pinned to English (assertions match the
English ARB values). Pass only the doubles you care about.

Fixtures build `Pokemon` with `sprites: null` so `PokemonCard` takes its `Icon`
branch. No network, no image-mocking package, and no pending `CachedNetworkImage`
timer to hang `pumpAndSettle`.

> `pumpAndSettle` hangs on any screen showing a `CircularProgressIndicator` —
> it is an animation that never settles. Use `pump()` there.

### Tests that were verified to fail

Several tests were checked against broken code rather than merely observed to
pass — worth doing for anything guarding a *silent* failure:

| Test | Fails without |
|---|---|
| `does not emit after close` | the `isClosed` guard |
| `routes build MaterialPage` | `MaterialPageRouteData` |
| `debounce collapses a burst` | the `EventTransformer` |
| `restartable drops a slow result` | `restartable()` — fails with `Expected 'pikachu' Actual 'pika'` |
| `transformTimeout → RequestTimeoutException` | the dio 5.11 mapping |

---

## Conventions

- **Lints** are a curated superset of `flutter/flutter`'s own options, audited
  against the installed analyzer. `analysis_options.yaml` records a reason next
  to every disabled rule; keep that up if you change one.
- **`always_specify_types`** is on, so write `final List<Pokemon> x = ...`, not
  `final x = ...`. This applies to `test/` too.
- **Formatter width is pinned to 80** in `analysis_options.yaml`. Run
  `dart format .`.
- **Comments explain *why*.** If a comment restates the line below it, delete it.
- **`analyze` must be clean.** It currently reports zero issues; keep it there.

---

## Known gaps

- **No in-app theme switch.** `AppTheme.darkTheme` is wired into `MaterialApp`
  and follows the system setting, but nothing in the app switches `themeMode`.
  A theme cubit would be ~30 lines.
- **iOS is unverified.** The UIScene and iOS 15 migration was applied by hand
  from the Flutter 3.47 migrator source; no Xcode was available to build or
  launch it. Verify before releasing.
- **Server-provided error strings are not localized** (see [Errors](#errors));
  the generic fallbacks are.
- **No retry/backoff on transient failures.** A single 503 on a page fetch
  surfaces as an error state (list) or a SnackBar (loadMore). A
  `RetryInterceptor` limited to idempotent GETs would go where the other
  interceptors do: the `Dio` registration in `service_locator.dart`.
- **The detail cache is unbounded.** ~1.5 KB per Pokémon and at most ~1350
  entries, so the ceiling is ~2 MB — acceptable, but worth an LRU if the data
  set were larger.
