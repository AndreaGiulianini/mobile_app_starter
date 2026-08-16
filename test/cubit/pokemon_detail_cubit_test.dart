import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app_starter/core/errors/app_exception.dart';
import 'package:mobile_app_starter/cubit/pokemon_detail_cubit.dart';
import 'package:mobile_app_starter/cubit/pokemon_detail_state.dart';
import 'package:mobile_app_starter/repository/pokemon_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fixtures.dart';

class MockPokemonRepository extends Mock implements PokemonRepository;

void main() {
  late MockPokemonRepository repository;

  setUpAll(() {
    registerFallbackValue(CancelToken());
  });

  setUp(() {
    repository = MockPokemonRepository();
  });

  group('PokemonDetailCubit', () {
    test('starts loading and fetches nothing until the view asks', () {
      final PokemonDetailCubit cubit = PokemonDetailCubit(repository, 1);

      expect(cubit.state, isA<PokemonDetailLoading>());
      verifyNever(
        () => repository.getById(any(), cancelToken: any(named: 'cancelToken')),
      );
    });

    blocTest<PokemonDetailCubit, PokemonDetailState>(
      'loads the requested Pokémon',
      setUp: () {
        when(
          () => repository.getById(25, cancelToken: any(named: 'cancelToken')),
        ).thenAnswer((_) async => buildPokemon(id: 25, name: 'pikachu'));
      },
      build: () => PokemonDetailCubit(repository, 25),
      act: (PokemonDetailCubit cubit) => cubit.load(),
      expect: () => <Matcher>[
        // The re-emit of the (equal) initial loading state, then the payload.
        isA<PokemonDetailLoading>(),
        isA<PokemonDetailLoaded>().having(
          (PokemonDetailLoaded s) => s.pokemon.name,
          'pokemon.name',
          'pikachu',
        ),
      ],
    );

    blocTest<PokemonDetailCubit, PokemonDetailState>(
      'surfaces the AppException message verbatim',
      setUp: () {
        // thenThrow is safe now that nothing fetches from a constructor: the
        // sync throw lands inside load()'s own try.
        when(
          () =>
              repository.getById(any(), cancelToken: any(named: 'cancelToken')),
        ).thenThrow(const NotFoundException('no such pokemon'));
      },
      build: () => PokemonDetailCubit(repository, 9999),
      act: (PokemonDetailCubit cubit) => cubit.load(),
      expect: () => <Matcher>[
        isA<PokemonDetailLoading>(),
        isA<PokemonDetailFailure>().having(
          (PokemonDetailFailure s) => s.message,
          'message',
          'no such pokemon',
        ),
      ],
    );

    blocTest<PokemonDetailCubit, PokemonDetailState>(
      'leaves the message null on an unexpected error, for the UI to localize',
      setUp: () {
        when(
          () =>
              repository.getById(any(), cancelToken: any(named: 'cancelToken')),
        ).thenThrow(Exception('boom'));
      },
      build: () => PokemonDetailCubit(repository, 1),
      act: (PokemonDetailCubit cubit) => cubit.load(),
      expect: () => <Matcher>[
        isA<PokemonDetailLoading>(),
        isA<PokemonDetailFailure>().having(
          (PokemonDetailFailure s) => s.message,
          'message',
          isNull,
        ),
      ],
    );

    test('load() can be called again to retry after a failure', () async {
      int calls = 0;
      when(() => repository.getById(1, cancelToken: any(named: 'cancelToken')))
          .thenAnswer((_) async {
            if (calls++ == 0) {
              throw const NetworkException('offline');
            }
            return buildPokemon(id: 1, name: 'bulbasaur');
          });

      final PokemonDetailCubit cubit = PokemonDetailCubit(repository, 1);
      await cubit.load();
      expect(cubit.state, isA<PokemonDetailFailure>());

      await cubit.load();
      expect(cubit.state, isA<PokemonDetailLoaded>());

      await cubit.close();
    });

    test('does not emit after close', () async {
      when(
        () => repository.getById(any(), cancelToken: any(named: 'cancelToken')),
      ).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return buildPokemon(id: 1, name: 'bulbasaur');
      });

      final PokemonDetailCubit cubit = PokemonDetailCubit(repository, 1);
      unawaited(cubit.load());
      await cubit.close();

      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(cubit.state, isA<PokemonDetailLoading>());
    });

    test('close cancels the in-flight request token', () async {
      late CancelToken token;
      when(
        () => repository.getById(any(), cancelToken: any(named: 'cancelToken')),
      ).thenAnswer((Invocation invocation) async {
        token = invocation.namedArguments[#cancelToken]! as CancelToken;
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return buildPokemon(id: 1, name: 'bulbasaur');
      });

      final PokemonDetailCubit cubit = PokemonDetailCubit(repository, 1);
      unawaited(cubit.load());
      await Future<void>.delayed(Duration.zero);
      await cubit.close();

      // Popping the route must stop the transport, not just the emit.
      expect(token.isCancelled, isTrue);
    });
  });
}
