import 'package:material_ui/material_ui.dart';

abstract final class AppTheme {
  static const Color _primaryLight = Color(0xFFDC0A2D); // Pokemon Red
  static const Color _secondaryLight = Color(0xFF3B4CCA); // Pokemon Blue

  // Lighter variants for dark mode.
  static const Color _primaryDark = Color(0xFFFF1C1C);
  static const Color _secondaryDark = Color(0xFF5B7BDB);

  // fromSeed, not ColorScheme.light()/dark() with four roles set by hand:
  // widgets already reach for seeded roles (surfaceContainerHighest,
  // onSurfaceVariant), which the baseline palette left unrelated to the
  // Pokémon colours.
  static ThemeData get lightTheme => _base(
    ColorScheme.fromSeed(seedColor: _primaryLight)
        .copyWith(primary: _primaryLight, secondary: _secondaryLight),
  );

  static ThemeData get darkTheme => _base(
    ColorScheme.fromSeed(
      seedColor: _primaryDark,
      brightness: Brightness.dark,
    ).copyWith(primary: _primaryDark, secondary: _secondaryDark),
  );

  /// One builder for both modes; light and dark used to duplicate these
  /// blocks verbatim.
  static ThemeData _base(ColorScheme colorScheme) {
    final bool isDark = colorScheme.brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarThemeData(
        centerTitle: false,
        elevation: 0,
        // Brand-red bar in light mode; standard dark surface in dark mode,
        // where a saturated red bar would glare.
        backgroundColor: isDark ? colorScheme.surface : colorScheme.primary,
        foregroundColor: isDark ? colorScheme.onSurface : colorScheme.onPrimary,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
      ),
    );
  }
}
