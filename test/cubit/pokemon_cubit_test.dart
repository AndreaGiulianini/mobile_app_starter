import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app_starter/core/errors/app_exception.dart';
import 'package:mobile_app_starter/cubit/pokemon_cubit.dart';
import 'package:mobile_app_starter/cubit/pokemon_state.dart';
import 'package:mobile_app_starter/model/classes/pokemon.dart';
import 'package:mobile_app_starter/model/classes/pokemon_page.dart';
import 'package:mobile_app_starter/repository/pokemon_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fixtures.dart';

class MockPokemonRepository extends Mock implements PokemonRepository;

void main() {
  late MockPokemonRepository repository;

  setUp(() {
    repository = MockPokemonRepository();
  });

  /// A distinct page per offset, so "appended, not replaced" is observable.
  void stubPages() {
    when(
      () => repository.getPage(
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).thenAnswer((Invocation invocation) async {
      final int offset = invocation.namedArguments[#offset] as int? ?? 0;
      return PokemonPage(
        items: List<Pokemon>.generate(
          20,
          (int i) =>
              buildPokemon(id: offset + i + 1, name: 'p${offset + i + 1}'),
        ),
        total: 100,
      );
    });
  }

  group('PokemonCubit', () {
    test('starts in PokemonInitial', () {
      expect(PokemonCubit(repository).state, const PokemonInitial());
    });

    blocTest<PokemonCubit, PokemonState>(
      'loadPokemon emits [PokemonLoading, PokemonSuccess]',
      setUp: stubPages,
      build: () => PokemonCubit(repository),
      act: (PokemonCubit cubit) => cubit.loadPokemon(),
      expect: () => <Matcher>[
        isA<PokemonLoading>(),
        isA<PokemonSuccess>()
            .having(
              (PokemonSuccess s) => s.pokemonList.length,
              'pokemonList.length',
              20,
            )
            .having((PokemonSuccess s) => s.hasMore, 'hasMore', isTrue),
      ],
    );

    blocTest<PokemonCubit, PokemonState>(
      'loadPokemon surfaces the AppException message verbatim',
      setUp: () {
        when(
          () => repository.getPage(
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenThrow(const NetworkException('No internet connection.'));
      },
      build: () => PokemonCubit(repository),
      act: (PokemonCubit cubit) => cubit.loadPokemon(),
      expect: () => <Matcher>[
        isA<PokemonLoading>(),
        isA<PokemonError>().having(
          (PokemonError s) => s.message,
          'message',
          'No internet connection.',
        ),
      ],
    );

    blocTest<PokemonCubit, PokemonState>(
      'loadPokemon falls back to a generic message on an unexpected error',
      setUp: () {
        when(
          () => repository.getPage(
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenThrow(Exception('boom'));
      },
      build: () => PokemonCubit(repository),
      act: (PokemonCubit cubit) => cubit.loadPokemon(),
      expect: () => <Matcher>[
        isA<PokemonLoading>(),
        isA<PokemonError>().having(
          (PokemonError s) => s.message,
          'message',
          'An unexpected error occurred. Please try again.',
        ),
      ],
    );

    blocTest<PokemonCubit, PokemonState>(
      'loadMore appends the next page to the existing list',
      setUp: stubPages,
      build: () => PokemonCubit(repository),
      // `seed:` works because nextOffset lives in the state, not a private
      // field. See ARCHITECTURE.md, "All state lives in the state".
      seed: () => PokemonSuccess(
        List<Pokemon>.generate(
          20,
          (int i) => buildPokemon(id: i + 1, name: 'p${i + 1}'),
        ),
        hasMore: true,
        nextOffset: 20,
      ),
      act: (PokemonCubit cubit) => cubit.loadMore(),
      expect: () => <Matcher>[
        isA<PokemonLoadingMore>().having(
          (PokemonLoadingMore s) => s.currentList.length,
          'currentList.length',
          20,
        ),
        isA<PokemonSuccess>().having(
          (PokemonSuccess s) => s.pokemonList.length,
          'pokemonList.length',
          40,
        ),
      ],
      verify: (_) {
        verify(() => repository.getPage(offset: 20)).called(1);
      },
    );

    blocTest<PokemonCubit, PokemonState>(
      'loadMore is a no-op outside PokemonSuccess',
      setUp: stubPages,
      build: () => PokemonCubit(repository),
      act: (PokemonCubit cubit) => cubit.loadMore(),
      expect: () => const <PokemonState>[],
      verify: (_) {
        verifyNever(
          () => repository.getPage(
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        );
      },
    );

    blocTest<PokemonCubit, PokemonState>(
      'a failed loadMore keeps the page already on screen',
      setUp: () {
        int calls = 0;
        when(
          () => repository.getPage(
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async {
          if (calls++ > 0) {
            throw const NetworkException('offline');
          }
          return PokemonPage(
            items: List<Pokemon>.generate(
              20,
              (int i) => buildPokemon(id: i + 1, name: 'p${i + 1}'),
            ),
            total: 100,
          );
        });
      },
      build: () => PokemonCubit(repository),
      act: (PokemonCubit cubit) async {
        await cubit.loadPokemon();
        await cubit.loadMore();
      },
      skip: 3,
      expect: () => <Matcher>[
        isA<PokemonSuccess>()
            .having(
              (PokemonSuccess s) => s.pokemonList.length,
              'pokemonList.length',
              20,
            )
            // The failure is not swallowed: the flag is the UI's SnackBar cue.
            .having(
              (PokemonSuccess s) => s.loadMoreFailed,
              'loadMoreFailed',
              isTrue,
            ),
      ],
    );

    test(
      'loadPokemon started mid-loadMore wins over the stale append',
      () async {
        final Completer<void> gate = Completer<void>();
        when(
          () => repository.getPage(
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((Invocation invocation) async {
          final int offset = invocation.namedArguments[#offset] as int? ?? 0;
          if (offset > 0) {
            // The appended page resolves only after the reload finished.
            await gate.future;
          }
          return PokemonPage(
            items: List<Pokemon>.generate(
              20,
              (int i) =>
                  buildPokemon(id: offset + i + 1, name: 'p${offset + i + 1}'),
            ),
            total: 100,
          );
        });

        final PokemonCubit cubit = PokemonCubit(repository);
        await cubit.loadPokemon();

        final Future<void> stale = cubit.loadMore();
        await cubit.loadPokemon(); // the user retried mid-append

        gate.complete();
        await stale;

        // Without the generation guard, the stale append emits last and the
        // list visibly rewinds to 40 items with a desynced offset.
        final PokemonSuccess state = cubit.state as PokemonSuccess;
        expect(state.pokemonList.length, 20);
        expect(state.nextOffset, 20);
        await cubit.close();
      },
    );

    test(
      'loadMore does not start a second fetch while one is in flight',
      () async {
        final Completer<void> gate = Completer<void>();
        int calls = 0;

        when(
          () => repository.getPage(
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((Invocation invocation) async {
          calls++;
          if (calls > 1) {
            await gate.future;
          }
          final int offset = invocation.namedArguments[#offset] as int? ?? 0;
          return PokemonPage(
            items: List<Pokemon>.generate(
              20,
              (int i) =>
                  buildPokemon(id: offset + i + 1, name: 'p${offset + i}'),
            ),
            total: 100,
          );
        });

        final PokemonCubit cubit = PokemonCubit(repository);
        await cubit.loadPokemon();

        final Future<void> first = cubit.loadMore();
        final Future<void> second = cubit.loadMore();

        gate.complete();
        await Future.wait(<Future<void>>[first, second]);

        // Initial load plus one loadMore; the second was rejected mid-flight.
        expect(calls, 2);
        await cubit.close();
      },
    );

    test('does not emit after close', () async {
      final Completer<void> gate = Completer<void>();
      when(
        () => repository.getPage(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async {
        await gate.future;
        return const PokemonPage(items: <Pokemon>[], total: 0);
      });

      final PokemonCubit cubit = PokemonCubit(repository);
      final Future<void> pending = cubit.loadPokemon();
      await cubit.close();

      gate.complete();

      // Throws without the isClosed guard in _safeEmit.
      await expectLater(pending, completes);
    });
  });
}
