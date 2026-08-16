import 'package:material_ui/material_ui.dart';
import 'package:mobile_app_starter/core/constants/pokemon_type_colors.dart';
import 'package:mobile_app_starter/core/extensions/string_extensions.dart';

/// Coloured pill showing a Pokémon type.
///
/// Two named constructors instead of a `size` parameter: the call sites only
/// ever want one of two sizes, and this keeps every field `final` so the whole
/// widget stays `const`.
class PokemonTypeChip extends StatelessWidget {
  /// For the grid card, where vertical space is tight.
  const PokemonTypeChip.small({required this.type, super.key})
    : _height = smallHeight,
      _fontSize = 10,
      _horizontalPadding = 8,
      _radius = 10;

  /// For the detail screen.
  const PokemonTypeChip.large({required this.type, super.key})
    : _height = 32,
      _fontSize = 14,
      _horizontalPadding = 14,
      _radius = 16;

  /// Height of a [PokemonTypeChip.small]. Public because the card sizes its
  /// type row to match, and the two must not drift apart.
  static const double smallHeight = 20;

  final String type;
  final double _height;
  final double _fontSize;
  final double _horizontalPadding;
  final double _radius;

  @override
  Widget build(BuildContext context) {
    final Color background = PokemonTypeColors.getTypeColor(type);
    // White-on-everything failed WCAG badly on the light type colours
    // (electric, ice); pick the label colour from the background's brightness.
    final Color foreground =
        ThemeData.estimateBrightnessForColor(background) == Brightness.dark
        ? Colors.white
        : Colors.black87;

    return Container(
      height: _height,
      padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(_radius),
      ),
      // Center with widthFactor: 1, not Container's `alignment`. Setting
      // `alignment` makes a Container expand to fill its constraints, so the
      // chip stayed compact inside the card's clipped row (unbounded) but
      // stretched full-width inside the detail screen's Wrap (bounded).
      child: Center(
        widthFactor: 1,
        child: Text(
          type.capitalized,
          style: TextStyle(
            color: foreground,
            fontSize: _fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
