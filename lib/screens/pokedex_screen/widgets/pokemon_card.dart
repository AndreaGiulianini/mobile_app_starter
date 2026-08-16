import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_app_starter/core/constants/artwork.dart';
import 'package:mobile_app_starter/core/extensions/string_extensions.dart';
import 'package:mobile_app_starter/l10n/app_localizations.dart';
import 'package:mobile_app_starter/model/classes/pokemon.dart';
import 'package:mobile_app_starter/router/routes.dart';
import 'package:mobile_app_starter/widgets/favorite_button.dart';
import 'package:mobile_app_starter/widgets/pokemon_type_chip.dart';

class PokemonCard extends StatelessWidget {
  const PokemonCard({required this.pokemon, super.key});

  final Pokemon pokemon;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String imageUrl =
        pokemon.sprites?.other?.officialArtwork?.frontDefault ??
        pokemon.sprites?.frontDefault ??
        '';
    // Decode near the ~200dp rendered width instead of the full artwork;
    // high-density screens cap out at the source size anyway.
    final int cacheWidth = math.min(
      kArtworkSourcePx,
      (200 * MediaQuery.devicePixelRatioOf(context)).round(),
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => PokemonDetailPage(id: pokemon.pokemonId).go(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // The two halves split the card evenly.
            Expanded(
              child: Hero(
                tag: 'pokemon-image-${pokemon.pokemonId}',
                child: Semantics(
                  image: true,
                  label: pokemon.name.capitalized,
                  child: ColoredBox(
                    color: colorScheme.surfaceContainerHighest,
                    child: imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.contain,
                            memCacheWidth: cacheWidth,
                            placeholder: (BuildContext context, String url) =>
                                const Center(
                                  child: CircularProgressIndicator(),
                                ),
                            errorWidget:
                                (
                                  BuildContext context,
                                  String url,
                                  Object error,
                                ) => Icon(
                                  Icons.error,
                                  size: 50,
                                  color: colorScheme.error,
                                ),
                          )
                        : Icon(
                            Icons.catching_pokemon,
                            size: 50,
                            color: colorScheme.onSurfaceVariant,
                          ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 4, 6),
                // Fixed-height rows, never a Spacer: a Spacer alongside
                // MainAxisSize.min overflowed this box, and the stats row drew
                // on top of the type chips.
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _HeaderRow(pokemon: pokemon),
                    _TypeRow(types: pokemon.types),
                    _StatsRow(pokemon: pokemon),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The card's dense 10px metadata style, shared by the number and the
/// height/weight row.
///
/// Explicit rather than a `textTheme` role on purpose: the card's layout tests
/// measure real geometry, and `labelSmall` is 11px — colour still comes from
/// the scheme.
TextStyle _metaStyle(BuildContext context, {required FontWeight weight}) =>
    TextStyle(
      fontSize: 10,
      fontWeight: weight,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.pokemon});

  final Pokemon pokemon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                AppLocalizations.of(
                  context,
                ).pokemonNumber(pokemon.pokemonId.toString().padLeft(3, '0')),
                style: _metaStyle(context, weight: FontWeight.bold),
              ),
              Text(
                pokemon.name.capitalized,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // No fixed 26dp box: the heart is the card's primary interaction and
        // needs a hit area near Material's 48dp minimum, not a quarter of it.
        FavoriteButton(pokemonId: pokemon.pokemonId, iconSize: 18),
      ],
    );
  }
}

class _TypeRow extends StatelessWidget {
  const _TypeRow({required this.types});

  final List<PokemonType>? types;

  @override
  Widget build(BuildContext context) {
    final List<PokemonType> list = types ?? const <PokemonType>[];
    if (list.isEmpty) {
      return const SizedBox.shrink();
    }

    // Clip, don't wrap and don't scroll: the card gives types a fixed-height
    // slot, so a wrapping row would push the stats out. Chips past the card's
    // width are cut off mid-chip, with no fade or indicator — acceptable
    // because three types is the maximum and the detail screen shows them all.
    //
    // Not a horizontal ListView: that put a whole Scrollable per card into the
    // gesture arena, fighting every tap and drag on the grid.
    return Semantics(
      label: AppLocalizations.of(context).pokemonTypeCount(list.length),
      child: SizedBox(
        height: PokemonTypeChip.smallHeight,
        width: double.infinity,
        child: ClipRect(
          child: OverflowBox(
            maxWidth: double.infinity,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: list
                  .map(
                    (PokemonType type) =>
                        PokemonTypeChip.small(type: type.type.name),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.pokemon});

  final Pokemon pokemon;

  @override
  Widget build(BuildContext context) {
    if (pokemon.height == null || pokemon.weight == null) {
      return const SizedBox.shrink();
    }

    final AppLocalizations l10n = AppLocalizations.of(context);
    final TextStyle style = _metaStyle(context, weight: FontWeight.w500);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          child: Text(
            l10n.pokemonHeight(pokemon.height! / 10),
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            l10n.pokemonWeight(pokemon.weight! / 10),
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
