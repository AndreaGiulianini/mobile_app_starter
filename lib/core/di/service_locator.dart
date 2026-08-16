import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_app_starter/bloc/favorites/favorites_bloc.dart';
import 'package:mobile_app_starter/bloc/search/search_bloc.dart';
import 'package:mobile_app_starter/core/config/app_config.dart';
import 'package:mobile_app_starter/cubit/pokemon_cubit.dart';
import 'package:mobile_app_starter/repository/pokemon_repository.dart';
import 'package:mobile_app_starter/service/client.dart';
import 'package:mobile_app_starter/utils/curl_logger.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  // Configured where Dio is created: ClientAPI must not mutate a dependency
  // it was handed, and the timeouts/base URL belong to the instance itself.
  getIt.registerLazySingleton<Dio>(() {
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        sendTimeout: AppConfig.sendTimeout,
      ),
    );
    // Compiled out of release builds by the dead-code eliminator.
    if (!kReleaseMode) {
      dio.interceptors.add(CurlLogger(printOnSuccess: true));
    }
    return dio;
  }, dispose: (Dio dio) => dio.close());

  getIt.registerLazySingleton<ClientAPI>(() => ClientAPI(dio: getIt<Dio>()));

  // Singleton: it caches the name index that search depends on.
  getIt.registerLazySingleton<PokemonRepository>(
    () => PokemonRepository(getIt<ClientAPI>()),
  );

  getIt.registerFactory<PokemonCubit>(
    () => PokemonCubit(getIt<PokemonRepository>()),
  );

  getIt.registerFactory<SearchBloc>(
    () => SearchBloc(getIt<PokemonRepository>()),
  );

  // Singleton so favourites stay consistent across screens. get_it owns it:
  // the provider in main.dart is `.value`, which never closes.
  getIt.registerLazySingleton<FavoritesBloc>(
    FavoritesBloc.new,
    dispose: (FavoritesBloc bloc) => bloc.close(),
  );
}

/// Clears every registration, running the `dispose` callbacks above.
/// Intended for `tearDown`.
Future<void> resetServiceLocator() => getIt.reset();
