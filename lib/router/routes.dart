import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_app_starter/router/material_page_route_data.dart';
import 'package:mobile_app_starter/screens/pokedex_screen/pokedex_screen.dart';
import 'package:mobile_app_starter/screens/pokemon_detail_screen/pokemon_detail_screen.dart';

part 'routes.g.dart';

// Every typed route must mix in MaterialPageRouteData — see that mixin.
@TypedGoRoute<PokedexScreenPage>(
  path: '/',
  routes: <TypedGoRoute<GoRouteData>>[
    TypedGoRoute<PokemonDetailPage>(path: 'pokemon/:id'),
  ],
)
class PokedexScreenPage extends GoRouteData
    with $PokedexScreenPage, MaterialPageRouteData {
  const PokedexScreenPage();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PokedexScreen();
}

/// Detail route, nested under the Pokédex so `pop` returns to the list.
class PokemonDetailPage extends GoRouteData
    with $PokemonDetailPage, MaterialPageRouteData {
  const PokemonDetailPage({required this.id});

  final int id;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      PokemonDetailScreen(id: id);
}
