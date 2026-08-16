import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_app_starter/bloc/favorites/favorites_bloc.dart';
import 'package:mobile_app_starter/bloc/search/search_bloc.dart';
import 'package:mobile_app_starter/core/config/app_config.dart';
import 'package:mobile_app_starter/core/di/service_locator.dart';
import 'package:mobile_app_starter/core/observers/app_bloc_observer.dart';
import 'package:mobile_app_starter/core/storage/app_storage.dart';
import 'package:mobile_app_starter/core/themes/app_theme.dart';
import 'package:mobile_app_starter/cubit/pokemon_cubit.dart';
import 'package:mobile_app_starter/l10n/app_localizations.dart';
import 'package:mobile_app_starter/repository/pokemon_repository.dart';
import 'package:mobile_app_starter/router/routes.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // One reporting seam for every error source, release included: without
  // these handlers (and the observer's onError) a release build silently
  // discards everything. Wire a crash reporter here when one is adopted.
  FlutterError.onError = FlutterError.presentError;
  WidgetsBinding.instance.platformDispatcher.onError =
      (Object error, StackTrace stackTrace) {
        developer.log(
          'Uncaught platform error',
          name: 'app',
          error: error,
          stackTrace: stackTrace,
        );
        return true;
      };

  // Not awaited: the grid is portrait-only by design, and blocking startup on
  // a platform round-trip to say so buys nothing.
  unawaited(
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]),
  );
  // Flavour selection: `flutter run --dart-define=ENV_FILE=.env.staging`.
  // These files ship as plaintext assets inside the binary — never put a
  // secret in them; sensitive values belong in --dart-define instead.
  await AppConfig.load(
    fileName: const String.fromEnvironment(
      'ENV_FILE',
      defaultValue: '.env.dev',
    ),
  );

  // Before any HydratedBloc is constructed.
  HydratedBloc.storage = await buildHydratedStorage(
    (await getApplicationDocumentsDirectory()).path,
  );

  Bloc.observer = AppBlocObserver();

  setupServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GoRouter _router = GoRouter(routes: $appRoutes);

  @override
  void dispose() {
    // GoRouter is a Listenable holding platform hooks; leak_tracker flags an
    // undisposed one in widget tests.
    _router.dispose();
    super.dispose();
  }

  // Ownership rule, and the reason each provider below is spelled the way it
  // is: `create:` for get_it factories, because the provider closing them on
  // unmount is exactly right. `.value` for get_it singletons, because get_it
  // owns those — a `create:` provider would close the singleton on unmount
  // and get_it would go on handing out the closed instance.
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<PokemonRepository>.value(
      // Above the blocs, so a screen can build its own cubit from it.
      value: getIt<PokemonRepository>(), // singleton
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<PokemonCubit>(
            // factory
            create: (BuildContext context) => getIt<PokemonCubit>(),
          ),
          BlocProvider<SearchBloc>(
            // factory
            create: (BuildContext context) => getIt<SearchBloc>(),
          ),
          // singleton
          BlocProvider<FavoritesBloc>.value(value: getIt<FavoritesBloc>()),
        ],
        child: MaterialApp.router(
          builder: (BuildContext context, Widget? child) =>
              // cached_network_image and octo_image still import the legacy
              // Material; the bridge maps this app's theme onto it. Deprecated
              // by design, being a migration shim. Remove once they migrate.
              // ignore: deprecated_member_use
              MaterialUiCompatibilityBridge(child: child!),
          // Localizes the OS task-switcher label too.
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context).appTitle,
          routerConfig: _router,
          // Already bundles the Material/Widgets/Cupertino global delegates.
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
        ),
      ),
    );
  }
}
