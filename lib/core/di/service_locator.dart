import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_app_starter/cubit/pokemon_cubit.dart';
import 'package:mobile_app_starter/service/client.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Register Dio
  getIt.registerLazySingleton<Dio>(() => Dio());

  // Register API Client
  getIt.registerLazySingleton<ClientAPI>(() => ClientAPI(dio: getIt<Dio>()));

  // Register Cubits as factories (new instance each time)
  getIt.registerFactory<PokemonCubit>(() => PokemonCubit(getIt<ClientAPI>()));
}
