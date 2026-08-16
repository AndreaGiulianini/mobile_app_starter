import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app_starter/core/di/service_locator.dart';
import 'package:mobile_app_starter/cubit/pokemon_cubit.dart';
import 'package:mobile_app_starter/service/client.dart';

void main() {
  tearDown(resetServiceLocator);

  group('setupServiceLocator', () {
    test('registers every dependency the app resolves at startup', () {
      setupServiceLocator();

      expect(getIt.isRegistered<Dio>(), isTrue);
      expect(getIt.isRegistered<ClientAPI>(), isTrue);
      expect(getIt.isRegistered<PokemonCubit>(), isTrue);
    });

    test('registers Dio and ClientAPI as singletons', () {
      setupServiceLocator();

      expect(identical(getIt<Dio>(), getIt<Dio>()), isTrue);
      expect(identical(getIt<ClientAPI>(), getIt<ClientAPI>()), isTrue);
    });

    test('registers PokemonCubit as a factory', () {
      setupServiceLocator();

      // A fresh cubit per BlocProvider, or a second route inherits a closed one.
      expect(identical(getIt<PokemonCubit>(), getIt<PokemonCubit>()), isFalse);
    });

    test('can be re-run after resetServiceLocator', () async {
      setupServiceLocator();
      await resetServiceLocator();

      expect(setupServiceLocator, returnsNormally);
    });
  });
}
