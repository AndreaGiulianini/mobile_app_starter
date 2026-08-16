import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// Application title. Shown in the app bar and in the OS task switcher.
  ///
  /// In en, this message translates to:
  /// **'Pokédex'**
  String get appTitle;

  /// Full-screen message shown while the first page of Pokémon is being fetched.
  ///
  /// In en, this message translates to:
  /// **'Loading Pokémon...'**
  String get pokedexLoading;

  /// Inline message shown below the grid while the next page is being fetched.
  ///
  /// In en, this message translates to:
  /// **'Loading more Pokémon...'**
  String get pokedexLoadingMore;

  /// Shown when the API returns successfully but with an empty list.
  ///
  /// In en, this message translates to:
  /// **'No Pokémon found'**
  String get pokedexEmpty;

  /// Label of the button that re-runs the request after a failure.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get pokedexRetry;

  /// SnackBar shown when fetching the next page fails; the list already on screen is kept.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load more Pokémon. Scroll again to retry.'**
  String get pokedexLoadMoreFailed;

  /// National Pokédex number shown on a Pokémon card. Zero-padded by the caller.
  ///
  /// In en, this message translates to:
  /// **'#{number}'**
  String pokemonNumber(String number);

  /// Height of a Pokémon in metres, shown on the card. The decimal separator follows the locale.
  ///
  /// In en, this message translates to:
  /// **'H: {meters} m'**
  String pokemonHeight(double meters);

  /// Weight of a Pokémon in kilograms, shown on the card. The decimal separator follows the locale.
  ///
  /// In en, this message translates to:
  /// **'W: {kilograms} kg'**
  String pokemonWeight(double kilograms);

  /// Screen-reader label for the row of type chips on a Pokémon card.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No types} =1{1 type} other{{count} types}}'**
  String pokemonTypeCount(int count);

  /// Placeholder inside the search field in the Pokedex app bar.
  ///
  /// In en, this message translates to:
  /// **'Search Pokémon'**
  String get searchHint;

  /// Shown when a search returns nothing.
  ///
  /// In en, this message translates to:
  /// **'No Pokémon matches “{query}”'**
  String searchNoResults(String query);

  /// Header above the search results list.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 result} other{{count} results}}'**
  String searchResultCount(int count);

  /// Shown when the search request errors out.
  ///
  /// In en, this message translates to:
  /// **'Search failed. Please try again.'**
  String get searchFailed;

  /// Accessibility label for the favourite toggle when not yet favourited.
  ///
  /// In en, this message translates to:
  /// **'Add to favourites'**
  String get favoriteAdd;

  /// Accessibility label for the favourite toggle when already favourited.
  ///
  /// In en, this message translates to:
  /// **'Remove from favourites'**
  String get favoriteRemove;

  /// Stat label on the detail screen.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get detailHeight;

  /// Stat label on the detail screen.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get detailWeight;

  /// Section heading above the type chips on the detail screen.
  ///
  /// In en, this message translates to:
  /// **'Types'**
  String get detailTypes;

  /// Shown when the detail request fails.
  ///
  /// In en, this message translates to:
  /// **'Could not load this Pokémon.'**
  String get detailLoadFailed;

  /// Section heading above the base-stat bars.
  ///
  /// In en, this message translates to:
  /// **'Base stats'**
  String get detailStats;

  /// Section heading above the ability chips.
  ///
  /// In en, this message translates to:
  /// **'Abilities'**
  String get detailAbilities;

  /// Badge marking an ability the API flags as hidden.
  ///
  /// In en, this message translates to:
  /// **'hidden'**
  String get detailAbilityHidden;

  /// Stat label for base_experience.
  ///
  /// In en, this message translates to:
  /// **'Base experience'**
  String get detailBaseExperience;

  /// Base stat: hit points.
  ///
  /// In en, this message translates to:
  /// **'HP'**
  String get statHp;

  /// Base stat: physical attack.
  ///
  /// In en, this message translates to:
  /// **'Attack'**
  String get statAttack;

  /// Base stat: physical defense.
  ///
  /// In en, this message translates to:
  /// **'Defense'**
  String get statDefense;

  /// Base stat: special attack, abbreviated to fit a narrow label column.
  ///
  /// In en, this message translates to:
  /// **'Sp. Atk'**
  String get statSpecialAttack;

  /// Base stat: special defense, abbreviated.
  ///
  /// In en, this message translates to:
  /// **'Sp. Def'**
  String get statSpecialDefense;

  /// Base stat: speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get statSpeed;

  /// Height with no prefix, for the detail screen where the row already carries a Height label.
  ///
  /// In en, this message translates to:
  /// **'{meters} m'**
  String valueMeters(double meters);

  /// Weight with no prefix, for the detail screen where the row already carries a Weight label.
  ///
  /// In en, this message translates to:
  /// **'{kilograms} kg'**
  String valueKilograms(double kilograms);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
