// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Pokédex';

  @override
  String get pokedexLoading => 'Caricamento Pokémon...';

  @override
  String get pokedexLoadingMore => 'Caricamento altri Pokémon...';

  @override
  String get pokedexEmpty => 'Nessun Pokémon trovato';

  @override
  String get pokedexRetry => 'Riprova';

  @override
  String get pokedexLoadMoreFailed =>
      'Impossibile caricare altri Pokémon. Scorri di nuovo per riprovare.';

  @override
  String pokemonNumber(String number) {
    return 'n. $number';
  }

  @override
  String pokemonHeight(double meters) {
    final intl.NumberFormat metersNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String metersString = metersNumberFormat.format(meters);

    return 'A: $metersString m';
  }

  @override
  String pokemonWeight(double kilograms) {
    final intl.NumberFormat kilogramsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String kilogramsString = kilogramsNumberFormat.format(kilograms);

    return 'P: $kilogramsString kg';
  }

  @override
  String pokemonTypeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tipi',
      one: '1 tipo',
      zero: 'Nessun tipo',
    );
    return '$_temp0';
  }

  @override
  String get searchHint => 'Cerca Pokémon';

  @override
  String searchNoResults(String query) {
    return 'Nessun Pokémon corrisponde a “$query”';
  }

  @override
  String searchResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count risultati',
      one: '1 risultato',
    );
    return '$_temp0';
  }

  @override
  String get searchFailed => 'Ricerca non riuscita. Riprova.';

  @override
  String get favoriteAdd => 'Aggiungi ai preferiti';

  @override
  String get favoriteRemove => 'Rimuovi dai preferiti';

  @override
  String get detailHeight => 'Altezza';

  @override
  String get detailWeight => 'Peso';

  @override
  String get detailTypes => 'Tipi';

  @override
  String get detailLoadFailed => 'Impossibile caricare questo Pokémon.';

  @override
  String get detailStats => 'Statistiche base';

  @override
  String get detailAbilities => 'Abilità';

  @override
  String get detailAbilityHidden => 'nascosta';

  @override
  String get detailBaseExperience => 'Esperienza base';

  @override
  String get statHp => 'PS';

  @override
  String get statAttack => 'Attacco';

  @override
  String get statDefense => 'Difesa';

  @override
  String get statSpecialAttack => 'Att. Sp.';

  @override
  String get statSpecialDefense => 'Dif. Sp.';

  @override
  String get statSpeed => 'Velocità';

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
