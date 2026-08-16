import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app_starter/bloc/search/search_bloc.dart';
import 'package:mobile_app_starter/bloc/search/search_event.dart';
import 'package:mobile_app_starter/bloc/search/search_state.dart';
import 'package:mobile_app_starter/core/errors/app_exception.dart';
import 'package:mobile_app_starter/model/classes/pokemon.dart';
import 'package:mobile_app_starter/repository/pokemon_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fixtures.dart';

class MockPokemonRepository extends Mock implements PokemonRepository;

/// Longer than [kSearchDebounce], so `wait:` lets the handler run.
const Duration _pastDebounce = Duration(milliseconds: 600);

void main() {
  late MockPokemonRepository repository;

  setUpAll(() {
    registerFallbackValue(CancelToken());
  });

  setUp(() {
    repository = MockPokemonRepository();
  });

  void stubSearch(List<Pokemon> results) {
    when(
      () => repository.searchByName(
        any(),
        limit: any(named: 'limit'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((_) async => results);
  }

  group('SearchBloc', () {
    test('starts idle', () {
      expect(SearchBloc(repository).state, const SearchIdle());
    });

    blocTest<SearchBloc, SearchState>(
      'a query emits [SearchLoading, SearchSuccess]',
      setUp: () => stubSearch(<Pokemon>[buildPokemon(id: 25, name: 'pikachu')]),
      build: () => SearchBloc(repository),
      act: (SearchBloc bloc) => bloc.add(const SearchQueryChanged('pika')),
      wait: _pastDebounce,
      expect: () => <Matcher>[
        isA<SearchLoading>(),
        isA<SearchSuccess>()
            .having((SearchSuccess s) => s.results.length, 'results.length', 1)
            .having((SearchSuccess s) => s.query, 'query', 'pika'),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'a query with no matches emits SearchEmpty carrying the query',
      setUp: () => stubSearch(<Pokemon>[]),
      build: () => SearchBloc(repository),
      act: (SearchBloc bloc) => bloc.add(const SearchQueryChanged('zzzz')),
      wait: _pastDebounce,
      expect: () => <Matcher>[
        isA<SearchLoading>(),
        isA<SearchEmpty>().having((SearchEmpty s) => s.query, 'query', 'zzzz'),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'an empty query resets to idle without hitting the repository',
      setUp: () => stubSearch(<Pokemon>[]),
      build: () => SearchBloc(repository),
      act: (SearchBloc bloc) => bloc.add(const SearchQueryChanged('   ')),
      wait: _pastDebounce,
      expect: () => <Matcher>[isA<SearchIdle>()],
      verify: (_) {
        verifyNever(
          () => repository.searchByName(
            any(),
            limit: any(named: 'limit'),
            cancelToken: any(named: 'cancelToken'),
          ),
        );
      },
    );

    blocTest<SearchBloc, SearchState>(
      'debounce collapses a burst of keystrokes into one request',
      setUp: () => stubSearch(<Pokemon>[buildPokemon(id: 25, name: 'pikachu')]),
      build: () => SearchBloc(repository),
      // Seven keystrokes typed faster than the debounce window.
      act: (SearchBloc bloc) {
        for (final String q in <String>[
          'p',
          'pi',
          'pik',
          'pika',
          'pikac',
          'pikach',
          'pikachu',
        ]) {
          bloc.add(SearchQueryChanged(q));
        }
      },
      wait: _pastDebounce,
      verify: (_) {
        // One request, for the last query only. Without debounce, seven.
        verify(
          () => repository.searchByName(
            'pikachu',
            cancelToken: any(named: 'cancelToken'),
          ),
        ).called(1);
        verifyNever(
          () => repository.searchByName(
            'p',
            cancelToken: any(named: 'cancelToken'),
          ),
        );
        verifyNever(
          () => repository.searchByName(
            'pika',
            cancelToken: any(named: 'cancelToken'),
          ),
        );
      },
    );

    test(
      'restartable drops a slow in-flight result when a newer query lands',
      () async {
        // "pika" resolves after "pikachu" was requested; without `restartable`
        // the stale result overwrites the fresh one.
        final Completer<List<Pokemon>> slow = Completer<List<Pokemon>>();

        when(
          () => repository.searchByName(
            'pika',
            limit: any(named: 'limit'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer((_) => slow.future);
        when(
          () => repository.searchByName(
            'pikachu',
            limit: any(named: 'limit'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer(
          (_) async => <Pokemon>[buildPokemon(id: 25, name: 'pikachu')],
        );

        final SearchBloc bloc = SearchBloc(repository);
        final List<SearchState> seen = <SearchState>[];
        final StreamSubscription<SearchState> sub = bloc.stream.listen(
          seen.add,
        );

        bloc.add(const SearchQueryChanged('pika'));
        await Future<void>.delayed(_pastDebounce);

        bloc.add(const SearchQueryChanged('pikachu'));
        await Future<void>.delayed(_pastDebounce);

        // Only now does the stale request finish.
        slow.complete(<Pokemon>[buildPokemon(id: 1, name: 'stale')]);
        await Future<void>.delayed(const Duration(milliseconds: 100));

        final Iterable<SearchSuccess> successes = seen
            .whereType<SearchSuccess>();
        expect(successes, isNotEmpty);
        for (final SearchSuccess s in successes) {
          expect(
            s.query,
            'pikachu',
            reason: 'a stale "pika" result leaked through restartable',
          );
        }

        await sub.cancel();
        await bloc.close();
      },
    );

    blocTest<SearchBloc, SearchState>(
      'a repository failure emits SearchFailure with its message',
      setUp: () {
        when(
          () => repository.searchByName(
            any(),
            limit: any(named: 'limit'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenThrow(const NetworkException('offline'));
      },
      build: () => SearchBloc(repository),
      act: (SearchBloc bloc) => bloc.add(const SearchQueryChanged('pika')),
      wait: _pastDebounce,
      expect: () => <Matcher>[
        isA<SearchLoading>(),
        isA<SearchFailure>().having(
          (SearchFailure s) => s.message,
          'message',
          'offline',
        ),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'SearchCleared resets immediately, without waiting for the debounce',
      setUp: () => stubSearch(<Pokemon>[]),
      build: () => SearchBloc(repository),
      act: (SearchBloc bloc) => bloc.add(const SearchCleared()),
      // No `wait:` — clearing must not be debounced.
      expect: () => <Matcher>[isA<SearchIdle>()],
    );

    test(
      'SearchCleared discards an in-flight query, transport included',
      () async {
        // The bug this guards: with separate on<E> handlers, a clear could not
        // cancel a running query, so its result reappeared on a cleared field.
        final Completer<List<Pokemon>> slow = Completer<List<Pokemon>>();
        late CancelToken token;
        when(
          () => repository.searchByName(
            'pika',
            limit: any(named: 'limit'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer((Invocation invocation) {
          token = invocation.namedArguments[#cancelToken]! as CancelToken;
          return slow.future;
        });

        final SearchBloc bloc = SearchBloc(repository);
        final List<SearchState> seen = <SearchState>[];
        final StreamSubscription<SearchState> sub = bloc.stream.listen(
          seen.add,
        );

        bloc.add(const SearchQueryChanged('pika'));
        await Future<void>.delayed(_pastDebounce); // request now in flight

        bloc.add(const SearchCleared());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(token.isCancelled, isTrue, reason: 'the HTTP work kept running');

        slow.complete(<Pokemon>[buildPokemon(id: 25, name: 'pikachu')]);
        // Past the debounced copy of the clear as well.
        await Future<void>.delayed(_pastDebounce);

        expect(
          seen.whereType<SearchSuccess>(),
          isEmpty,
          reason: 'stale results reappeared on a cleared field',
        );
        expect(bloc.state, const SearchIdle());

        await sub.cancel();
        await bloc.close();
      },
    );

    test(
      'a query still pending in the debounce window dies with the clear',
      () async {
        stubSearch(<Pokemon>[buildPokemon(id: 25, name: 'pikachu')]);

        final SearchBloc bloc = SearchBloc(repository);
        bloc.add(const SearchQueryChanged('pika'));
        // Clear arrives before the debounce elapses.
        await Future<void>.delayed(const Duration(milliseconds: 50));
        bloc.add(const SearchCleared());
        await Future<void>.delayed(_pastDebounce);

        verifyNever(
          () => repository.searchByName(
            any(),
            limit: any(named: 'limit'),
            cancelToken: any(named: 'cancelToken'),
          ),
        );
        expect(bloc.state, const SearchIdle());
        await bloc.close();
      },
    );
  });
}
