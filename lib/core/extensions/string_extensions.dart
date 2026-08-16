extension StringCasing on String {
  /// `bulbasaur` -> `Bulbasaur`.
  String get capitalized =>
      isEmpty ? this : this[0].toUpperCase() + substring(1);

  /// `special-attack` -> `Special Attack`. For the hyphenated keys the API
  /// returns for stats and abilities.
  String get titleCased =>
      split('-').map((String word) => word.capitalized).join(' ');
}
