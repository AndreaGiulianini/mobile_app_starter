// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$pokedexScreenPage];

RouteBase get $pokedexScreenPage => GoRouteData.$route(
  path: '/',
  hasOverriddenOnExit: false,
  factory: $PokedexScreenPage._fromState,
  routes: [
    GoRouteData.$route(
      path: 'pokemon/:id',
      hasOverriddenOnExit: false,
      factory: $PokemonDetailPage._fromState,
    ),
  ],
);

mixin $PokedexScreenPage on GoRouteData {
  static PokedexScreenPage _fromState(GoRouterState state) =>
      const PokedexScreenPage();

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

mixin $PokemonDetailPage on GoRouteData {
  static PokemonDetailPage _fromState(GoRouterState state) =>
      PokemonDetailPage(id: int.parse(state.pathParameters['id']!));

  PokemonDetailPage get _self => this as PokemonDetailPage;

  @override
  String get location => GoRouteData.$location(
    '/pokemon/${Uri.encodeComponent(_self.id.toString())}',
  );

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
