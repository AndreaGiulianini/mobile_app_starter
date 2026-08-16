import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_app_starter/bloc/search/search_event.dart';
import 'package:mobile_app_starter/bloc/search/search_state.dart';
import 'package:mobile_app_starter/cubit/pokemon_cubit.dart';
import 'package:mobile_app_starter/cubit/pokemon_state.dart';
import 'package:mobile_app_starter/model/classes/pokemon.dart';
import 'package:mobile_app_starter/screens/pokedex_screen/pokedex_screen.dart';
import 'package:mobile_app_starter/screens/pokedex_screen/widgets/pokemon_card.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fixtures.dart';
import '../helpers/pump_app.dart';

void main() {
  group('PokedexScreen', () {
    testWidgets('renders one card per Pokémon on success', (
      WidgetTester tester,
    ) async {
      final MockPokemonCubit cubit = MockPokemonCubit();
      when(() => cubit.loadPokemon()).thenAnswer((_) async {});
      whenListen(
        cubit,
        const Stream<PokemonState>.empty(),
        initialState: PokemonSuccess(
          <Pokemon>[
            buildPokemon(id: 1, name: 'bulbasaur'),
            buildPokemon(id: 2, name: 'ivysaur'),
          ],
          hasMore: false,
          nextOffset: 2,
        ),
      );

      await tester.pumpApp(const PokedexScreen(), pokemonCubit: cubit);
      await tester.pumpAndSettle();

      expect(find.byType(PokemonCard), findsNWidgets(2));
      // Capitalised by StringCasing.capitalized.
      expect(find.text('Bulbasaur'), findsOneWidget);
      // Fixtures have sprites: null, so the placeholder icon renders and no
      // image request is made.
      expect(find.byIcon(Icons.catching_pokemon), findsNWidgets(2));
    });

    testWidgets('shows the localized empty message', (
      WidgetTester tester,
    ) async {
      final MockPokemonCubit cubit = MockPokemonCubit();
      when(() => cubit.loadPokemon()).thenAnswer((_) async {});
      whenListen(
        cubit,
        const Stream<PokemonState>.empty(),
        initialState: const PokemonSuccess(
          <Pokemon>[],
          hasMore: false,
          nextOffset: 0,
        ),
      );

      await tester.pumpApp(const PokedexScreen(), pokemonCubit: cubit);
      await tester.pumpAndSettle();

      expect(find.text('No Pokémon found'), findsOneWidget);
    });

    testWidgets('shows the error and wires Retry to the cubit', (
      WidgetTester tester,
    ) async {
      final MockPokemonCubit cubit = MockPokemonCubit();
      when(() => cubit.loadPokemon()).thenAnswer((_) async {});
      when(() => cubit.retry()).thenAnswer((_) async {});
      whenListen(
        cubit,
        const Stream<PokemonState>.empty(),
        initialState: const PokemonError('No internet connection.'),
      );

      await tester.pumpApp(const PokedexScreen(), pokemonCubit: cubit);
      await tester.pumpAndSettle();

      expect(find.text('No internet connection.'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Retry'));
      await tester.pump();

      verify(() => cubit.retry()).called(1);
    });

    testWidgets('typing dispatches SearchQueryChanged on every keystroke', (
      WidgetTester tester,
    ) async {
      // One event per keystroke; debouncing is the bloc's job.
      final MockSearchBloc search = MockSearchBloc();
      whenListen(
        search,
        const Stream<SearchState>.empty(),
        initialState: const SearchIdle(),
      );

      // pump(), not pumpAndSettle(): the spinner never settles.
      await tester.pumpApp(const PokedexScreen(), searchBloc: search);
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'pik');
      await tester.pump();

      verify(() => search.add(const SearchQueryChanged('pik'))).called(1);
    });

    testWidgets('search results replace the paginated grid', (
      WidgetTester tester,
    ) async {
      final MockSearchBloc search = MockSearchBloc();
      whenListen(
        search,
        const Stream<SearchState>.empty(),
        initialState: SearchSuccess(<Pokemon>[
          buildPokemon(id: 25, name: 'pikachu'),
        ], query: 'pika'),
      );

      await tester.pumpApp(const PokedexScreen(), searchBloc: search);
      await tester.pumpAndSettle();

      expect(find.text('1 result'), findsOneWidget);
      expect(find.byType(PokemonCard), findsOneWidget);
      expect(find.text('Pikachu'), findsOneWidget);
    });

    testWidgets('an empty search shows the query back to the user', (
      WidgetTester tester,
    ) async {
      final MockSearchBloc search = MockSearchBloc();
      whenListen(
        search,
        const Stream<SearchState>.empty(),
        initialState: const SearchEmpty('zzzz'),
      );

      await tester.pumpApp(const PokedexScreen(), searchBloc: search);
      await tester.pumpAndSettle();

      expect(find.textContaining('zzzz'), findsOneWidget);
    });

    testWidgets('scrolling near the bottom asks for the next page', (
      WidgetTester tester,
    ) async {
      final MockPokemonCubit cubit = MockPokemonCubit();
      when(() => cubit.loadPokemon()).thenAnswer((_) async {});
      when(() => cubit.loadMore()).thenAnswer((_) async {});
      whenListen(
        cubit,
        const Stream<PokemonState>.empty(),
        initialState: PokemonSuccess(
          List<Pokemon>.generate(
            30,
            (int i) => buildPokemon(id: i + 1, name: 'p${i + 1}'),
          ),
          hasMore: true,
          nextOffset: 30,
        ),
      );

      await tester.pumpApp(const PokedexScreen(), pokemonCubit: cubit);
      await tester.pump();

      await tester.fling(find.byType(GridView), const Offset(0, -2000), 3000);
      await tester.pumpAndSettle();

      verify(() => cubit.loadMore()).called(greaterThanOrEqualTo(1));
    });

    testWidgets('search results never trigger pagination', (
      WidgetTester tester,
    ) async {
      // The documented contract of PokemonGrid.controller: search results are
      // a single page, so their grid gets no controller and no infinite
      // scroll.
      final MockSearchBloc search = MockSearchBloc();
      whenListen(
        search,
        const Stream<SearchState>.empty(),
        initialState: SearchSuccess(
          List<Pokemon>.generate(
            30,
            (int i) => buildPokemon(id: i + 1, name: 'p${i + 1}'),
          ),
          query: 'p',
        ),
      );
      final PokemonCubit cubit = buildMockPokemonCubit();

      await tester.pumpApp(
        const PokedexScreen(),
        pokemonCubit: cubit,
        searchBloc: search,
      );
      await tester.pump();

      await tester.fling(find.byType(GridView), const Offset(0, -2000), 3000);
      await tester.pumpAndSettle();

      verifyNever(() => cubit.loadMore());
    });

    testWidgets('a failed loadMore surfaces as a SnackBar over the list', (
      WidgetTester tester,
    ) async {
      final MockPokemonCubit cubit = MockPokemonCubit();
      when(() => cubit.loadPokemon()).thenAnswer((_) async {});
      final List<Pokemon> pokemonList = <Pokemon>[
        buildPokemon(id: 1, name: 'bulbasaur'),
      ];
      whenListen(
        cubit,
        Stream<PokemonState>.fromIterable(<PokemonState>[
          PokemonSuccess(
            pokemonList,
            hasMore: true,
            nextOffset: 20,
            loadMoreFailed: true,
          ),
        ]),
        initialState: PokemonSuccess(
          pokemonList,
          hasMore: true,
          nextOffset: 20,
        ),
      );

      await tester.pumpApp(const PokedexScreen(), pokemonCubit: cubit);
      await tester.pump();
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      // The list stays on screen underneath.
      expect(find.byType(PokemonCard), findsOneWidget);
    });

    testWidgets('a search failure surfaces as a SnackBar, not a page', (
      WidgetTester tester,
    ) async {
      // The grid must stay on screen underneath.
      final MockSearchBloc search = MockSearchBloc();
      whenListen(
        search,
        Stream<SearchState>.fromIterable(const <SearchState>[
          SearchFailure('offline'),
        ]),
        initialState: const SearchIdle(),
      );

      await tester.pumpApp(const PokedexScreen(), searchBloc: search);
      await tester.pump();
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('offline'), findsOneWidget);
    });
  });
}
