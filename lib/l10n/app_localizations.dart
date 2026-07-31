import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme Park App'**
  String get appTitle;

  /// No description provided for @home_welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Theme Park'**
  String get home_welcome;

  /// No description provided for @home_counter_label.
  ///
  /// In en, this message translates to:
  /// **'You have pushed the button this many times:'**
  String get home_counter_label;

  /// No description provided for @details_title.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details_title;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_page.
  ///
  /// In en, this message translates to:
  /// **'Settings page'**
  String get settings_page;

  /// No description provided for @nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// No description provided for @nav_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get nav_settings;

  /// No description provided for @nav_search.
  ///
  /// In en, this message translates to:
  /// **'AI Search'**
  String get nav_search;

  /// No description provided for @increment_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Increment'**
  String get increment_tooltip;

  /// No description provided for @details_button.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details_button;

  /// No description provided for @settings_button.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_button;

  /// No description provided for @filter_thrill.
  ///
  /// In en, this message translates to:
  /// **'Thrill'**
  String get filter_thrill;

  /// No description provided for @filter_toddler.
  ///
  /// In en, this message translates to:
  /// **'Toddler'**
  String get filter_toddler;

  /// No description provided for @filter_indoor.
  ///
  /// In en, this message translates to:
  /// **'Indoor'**
  String get filter_indoor;

  /// No description provided for @filter_dining.
  ///
  /// In en, this message translates to:
  /// **'Dining'**
  String get filter_dining;

  /// No description provided for @heatmap_toggle.
  ///
  /// In en, this message translates to:
  /// **'Crowd Heatmap'**
  String get heatmap_toggle;

  /// No description provided for @walking_radius.
  ///
  /// In en, this message translates to:
  /// **'5-Min Walking Radius'**
  String get walking_radius;

  /// No description provided for @toggle_map.
  ///
  /// In en, this message translates to:
  /// **'Show Map'**
  String get toggle_map;

  /// No description provided for @toggle_list.
  ///
  /// In en, this message translates to:
  /// **'Show List'**
  String get toggle_list;

  /// No description provided for @history_slider.
  ///
  /// In en, this message translates to:
  /// **'Crowd History (Hours)'**
  String get history_slider;

  /// No description provided for @onboarding_title.
  ///
  /// In en, this message translates to:
  /// **'Enable location for in-park features'**
  String get onboarding_title;

  /// No description provided for @onboarding_body.
  ///
  /// In en, this message translates to:
  /// **'We use your location to show nearby attractions, live wait times, and context-aware maps while you are in the park.'**
  String get onboarding_body;

  /// No description provided for @onboarding_request_button.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get onboarding_request_button;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;
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
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
