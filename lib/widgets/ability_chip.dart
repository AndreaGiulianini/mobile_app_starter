import 'package:material_ui/material_ui.dart';
import 'package:mobile_app_starter/core/extensions/string_extensions.dart';

/// A Pokémon ability. Hidden abilities are outlined, regular ones filled.
class AbilityChip extends StatelessWidget {
  const AbilityChip({
    required this.name,
    required this.isHidden,
    required this.hiddenLabel,
    super.key,
  });

  final String name;
  final bool isHidden;

  /// Suffix marking a hidden ability, already localized by the caller.
  final String hiddenLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isHidden
            ? Colors.transparent
            : colors.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isHidden ? colors.outline : colors.secondary),
      ),
      child: Text(
        isHidden ? '${name.titleCased} ($hiddenLabel)' : name.titleCased,
        style: TextStyle(
          color: colors.onSurface,
          fontWeight: isHidden ? FontWeight.normal : FontWeight.w600,
        ),
      ),
    );
  }
}
