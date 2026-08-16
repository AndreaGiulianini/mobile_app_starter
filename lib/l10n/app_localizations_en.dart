// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pokédex';

  @override
  String get pokedexLoading => 'Loading Pokémon...';

  @override
  String get pokedexLoadingMore => 'Loading more Pokémon...';

  @override
  String get pokedexEmpty => 'No Pokémon found';

  @override
  String get pokedexRetry => 'Retry';

  @override
  String get pokedexLoadMoreFailed =>
      'Couldn\'t load more Pokémon. Scroll again to retry.';

  @override
  String pokemonNumber(String number) {
    return '#$number';
  }

  @override
  String pokemonHeight(double meters) {
    final intl.NumberFormat metersNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String metersString = metersNumberFormat.format(meters);

    return 'H: $metersString m';
  }

  @override
  String pokemonWeight(double kilograms) {
    final intl.NumberFormat kilogramsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String kilogramsString = kilogramsNumberFormat.format(kilograms);

    return 'W: $kilogramsString kg';
  }

  @override
  String pokemonTypeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count types',
      one: '1 type',
      zero: 'No types',
    );
    return '$_temp0';
  }

  @override
  String get searchHint => 'Search Pokémon';

  @override
  String searchNoResults(String query) {
    return 'No Pokémon matches “$query”';
  }

  @override
  String searchResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
    );
    return '$_temp0';
  }

  @override
  String get searchFailed => 'Search failed. Please try again.';

  @override
  String get favoriteAdd => 'Add to favourites';

  @override
  String get favoriteRemove => 'Remove from favourites';

  @override
  String get detailHeight => 'Height';

  @override
  String get detailWeight => 'Weight';

  @override
  String get detailTypes => 'Types';

  @override
  String get detailLoadFailed => 'Could not load this Pokémon.';

  @override
  String get detailStats => 'Base stats';

  @override
  String get detailAbilities => 'Abilities';

  @override
  String get detailAbilityHidden => 'hidden';

  @override
  String get detailBaseExperience => 'Base experience';

  @override
  String get statHp => 'HP';

  @override
  String get statAttack => 'Attack';

  @override
  String get statDefense => 'Defense';

  @override
  String get statSpecialAttack => 'Sp. Atk';

  @override
  String get statSpecialDefense => 'Sp. Def';

  @override
  String get statSpeed => 'Speed';

  @override
  String valueMeters(double meters) {
    final intl.NumberFormat metersNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String metersString = metersNumberFormat.format(meters);

    return '$metersString m';
  }

  @override
  String valueKilograms(double kilograms) {
    final intl.NumberFormat kilogramsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String kilogramsString = kilogramsNumberFormat.format(kilograms);

    return '$kilogramsString kg';
  }
}
