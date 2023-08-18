// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $splashScreenPage,
    ];

RouteBase get $splashScreenPage => GoRouteData.$route(
      path: '/',
      factory: $SplashScreenPageExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: 'home',
          factory: $HomeScreenPageExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'maintenance',
          factory: $MaintenanceScreenPageExtension._fromState,
        ),
      ],
    );

extension $SplashScreenPageExtension on SplashScreenPage {
  static SplashScreenPage _fromState(GoRouterState state) => SplashScreenPage();

  String get location => GoRouteData.$location(
        '/',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $HomeScreenPageExtension on HomeScreenPage {
  static HomeScreenPage _fromState(GoRouterState state) => HomeScreenPage();

  String get location => GoRouteData.$location(
        '/home',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $MaintenanceScreenPageExtension on MaintenanceScreenPage {
  static MaintenanceScreenPage _fromState(GoRouterState state) =>
      MaintenanceScreenPage();

  String get location => GoRouteData.$location(
        '/maintenance',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
