// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$pokedexScreenPage];

RouteBase get $pokedexScreenPage =>
    GoRouteData.$route(path: '/', factory: $PokedexScreenPage._fromState);

mixin $PokedexScreenPage on GoRouteData {
  static PokedexScreenPage _fromState(GoRouterState state) =>
      PokedexScreenPage();

  @override
  String get location => GoRouteData.$location('/');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
