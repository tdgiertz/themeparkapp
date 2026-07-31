// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Theme Park App';

  @override
  String get home_welcome => 'Welcome to Theme Park';

  @override
  String get home_counter_label =>
      'You have pushed the button this many times:';

  @override
  String get details_title => 'Details';

  @override
  String get back => 'Back';

  @override
  String get reload => 'Reload';

  @override
  String get retry => 'Retry';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_page => 'Settings page';

  @override
  String get nav_home => 'Home';

  @override
  String get nav_settings => 'Settings';

  @override
  String get nav_search => 'AI Search';

  @override
  String get increment_tooltip => 'Increment';

  @override
  String get details_button => 'Details';

  @override
  String get settings_button => 'Settings';

  @override
  String get filter_thrill => 'Thrill';

  @override
  String get filter_toddler => 'Toddler';

  @override
  String get filter_indoor => 'Indoor';

  @override
  String get filter_dining => 'Dining';

  @override
  String get heatmap_toggle => 'Crowd Heatmap';

  @override
  String get walking_radius => '5-Min Walking Radius';

  @override
  String get toggle_map => 'Show Map';

  @override
  String get toggle_list => 'Show List';

  @override
  String get history_slider => 'Crowd History (Hours)';

  @override
  String get onboarding_title => 'Enable location for in-park features';

  @override
  String get onboarding_body =>
      'We use your location to show nearby attractions, live wait times, and context-aware maps while you are in the park.';

  @override
  String get onboarding_request_button => 'Request';

  @override
  String get skip => 'Skip';

  @override
  String get continueText => 'Continue';
}
