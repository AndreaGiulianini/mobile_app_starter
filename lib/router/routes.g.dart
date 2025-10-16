// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$pokedexScreenPage];

RouteBase get $pokedexScreenPage => GoRouteData.$route(
  path: '/',
  factory: $PokedexScreenPage._fromState,
  routes: [
    GoRouteData.$route(path: 'home', factory: $HomeScreenPage._fromState),
    GoRouteData.$route(path: 'maintenance', factory: $MaintenanceScreenPage._fromState),
  ],
);

mixin $PokedexScreenPage on GoRouteData {
  static PokedexScreenPage _fromState(GoRouterState state) => PokedexScreenPage();

  @override
  String get location => GoRouteData.$location('/');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $HomeScreenPage on GoRouteData {
  static HomeScreenPage _fromState(GoRouterState state) => HomeScreenPage();

  @override
  String get location => GoRouteData.$location('/home');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $MaintenanceScreenPage on GoRouteData {
  static MaintenanceScreenPage _fromState(GoRouterState state) => MaintenanceScreenPage();

  @override
  String get location => GoRouteData.$location('/maintenance');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
