import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile_app_starter/screens/home_screen/home_screen.dart';
import 'package:mobile_app_starter/screens/maintenance_screen/maintenance_screen.dart';
import 'package:mobile_app_starter/screens/splash_screen/splash_screen.dart';

part 'routes.g.dart';

@TypedGoRoute<SplashScreenPage>(
  path: '/',
  routes: <TypedGoRoute<GoRouteData>>[
    TypedGoRoute<HomeScreenPage>(
      path: 'home',
    ),
    TypedGoRoute<MaintenanceScreenPage>(
      path: 'maintenance',
    ),
  ],
)
class SplashScreenPage extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SplashScreen();
}

class HomeScreenPage extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}

class MaintenanceScreenPage extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const MaintenanceScreen();
}
