import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_app_starter/bloc/favorites/favorites_bloc.dart';
import 'package:mobile_app_starter/bloc/favorites/favorites_event.dart';
import 'package:mobile_app_starter/bloc/favorites/favorites_state.dart';
import 'package:mobile_app_starter/l10n/app_localizations.dart';

/// Heart toggle for a single Pokémon.
///
/// [BlocSelector], not [BlocBuilder]: favourites state changes on every toggle,
/// so a builder would rebuild every visible card. See ARCHITECTURE.md,
/// "Choosing a bloc widget".
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    required this.pokemonId,
    this.iconSize,
    this.activeColor,
    super.key,
  });

  final int pokemonId;
  final double? iconSize;

  /// Colour of the filled heart. Defaults to the scheme's error role — its
  /// "red" — which reads on card surfaces in both modes. Callers placing the
  /// button on a coloured background (the light-mode app bar) pass their own.
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return BlocSelector<FavoritesBloc, FavoritesState, bool>(
      selector: (FavoritesState state) => state.contains(pokemonId),
      builder: (BuildContext context, bool isFavorite) {
        return IconButton(
          tooltip: isFavorite ? l10n.favoriteRemove : l10n.favoriteAdd,
          padding: EdgeInsets.zero,
          iconSize: iconSize,
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite
                ? (activeColor ?? Theme.of(context).colorScheme.error)
                : null,
          ),
          onPressed: () =>
              context.read<FavoritesBloc>().add(FavoriteToggled(pokemonId)),
        );
      },
    );
  }
}
