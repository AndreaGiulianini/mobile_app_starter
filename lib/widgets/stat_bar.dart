import 'package:material_ui/material_ui.dart';

/// A named value drawn as a labelled progress bar.
class StatBar extends StatelessWidget {
  const StatBar({
    required this.label,
    required this.value,
    this.max = maxBaseStat,
    super.key,
  });

  /// The highest a base stat reaches in the games, so the natural full bar.
  static const int maxBaseStat = 255;

  final String label;
  final int value;
  final int max;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 76,
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '$value',
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (value / max).clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
