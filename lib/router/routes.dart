import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_starter/screens/home_screen/home_screen.dart';
import 'package:mobile_app_starter/screens/maintenance_screen/maintenance_screen.dart';
import 'package:mobile_app_starter/screens/pokedex_screen/pokedex_screen.dart';

part 'routes.g.dart';

@TypedGoRoute<PokedexScreenPage>(
  path: '/',
  routes: <TypedGoRoute<GoRouteData>>[
    TypedGoRoute<HomeScreenPage>(path: 'home'),
    TypedGoRoute<MaintenanceScreenPage>(path: 'maintenance'),
  ],
)
class PokedexScreenPage extends GoRouteData with $PokedexScreenPage {
  @override
  Widget build(BuildContext context, GoRouterState state) => const PokedexScreen();
}

class HomeScreenPage extends GoRouteData with $HomeScreenPage {
  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}

class MaintenanceScreenPage extends GoRouteData with $MaintenanceScreenPage {
  @override
  Widget build(BuildContext context, GoRouterState state) => const MaintenanceScreen();
}
