import 'package:material_ui/material_ui.dart';
import 'package:mobile_app_starter/model/classes/pokemon.dart';
import 'package:mobile_app_starter/screens/pokedex_screen/widgets/pokemon_card.dart';
import 'package:mobile_app_starter/widgets/app_state_views.dart';

/// Two-column grid of [PokemonCard]s, shared by the paginated list and the
/// search results.
///
/// [controller] is what separates the two uses: the paginated list passes one
/// to drive infinite scroll, search results pass none because they are a single
/// page and must never trigger `loadMore`.
class PokemonGrid extends StatelessWidget {
  const PokemonGrid({
    required this.pokemonList,
    this.controller,
    this.header,
    this.footer,
    super.key,
  });

  /// Scales with width instead of a fixed column count: phones still get two
  /// columns, a tablet gets as many ~200dp columns as fit rather than two
  /// enormous cards.
  static const SliverGridDelegateWithMaxCrossAxisExtent gridDelegate =
      SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      );

  final List<Pokemon> pokemonList;
  final ScrollController? controller;

  /// Caption above the grid, e.g. a search result count.
  final String? header;

  /// Strip below the grid, e.g. [AppLoadingMoreIndicator].
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final String? headerText = header;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          if (headerText != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  headerText,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
          Expanded(
            child: GridView.builder(
              controller: controller,
              gridDelegate: gridDelegate,
              itemCount: pokemonList.length,
              itemBuilder: (BuildContext context, int index) {
                final Pokemon pokemon = pokemonList[index];
                return PokemonCard(
                  key: ValueKey<int>(pokemon.pokemonId),
                  pokemon: pokemon,
                );
              },
            ),
          ),
          // Null-aware element: contributes nothing when `footer` is null.
          ?footer,
        ],
      ),
    );
  }
}
