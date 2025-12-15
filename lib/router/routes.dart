import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_starter/screens/pokedex_screen/pokedex_screen.dart';

part 'routes.g.dart';

@TypedGoRoute<PokedexScreenPage>(path: '/')
class PokedexScreenPage extends GoRouteData with $PokedexScreenPage {
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PokedexScreen();
}
