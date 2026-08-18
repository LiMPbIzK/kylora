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

  /// Title of the application shown in the window and launcher.
  ///
  /// In en, this message translates to:
  /// **'Kylora'**
  String get appTitle;

  /// Title of the sign-in screen.
  ///
  /// In en, this message translates to:
  /// **'Connect to IPTV'**
  String get loginTitle;

  /// Label of the Xtream server URL field.
  ///
  /// In en, this message translates to:
  /// **'Server URL'**
  String get serverUrl;

  /// Label of the username field.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Label of the password field.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Button to authenticate with the Xtream provider.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginButton;

  /// Shown when the Xtream server rejects the URL or credentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid URL or credentials'**
  String get loginErrorInvalidCredentials;

  /// Shown when the server is unreachable.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the server. Check the URL and your connection.'**
  String get loginErrorNetwork;

  /// Shown when an unexpected error occurs during sign-in.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error. Try again.'**
  String get loginErrorUnknown;

  /// Validation message for an empty required field.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationRequired;

  /// Validation message for a malformed server URL.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid URL (e.g. http://server:8080)'**
  String get validationInvalidUrl;

  /// Button to close the current session.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// Section label showing the account state.
  ///
  /// In en, this message translates to:
  /// **'Account status'**
  String get accountStatus;

  /// Status text when the account is active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get accountActive;

  /// Status text when the account is expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get accountExpired;

  /// Expiration date of the account. {date} is a formatted date.
  ///
  /// In en, this message translates to:
  /// **'Expires on {date}'**
  String accountExpiresOn(String date);

  /// Active and maximum connections. {active} and {max} are numbers.
  ///
  /// In en, this message translates to:
  /// **'Connections: {active}/{max}'**
  String accountConnections(String active, String max);

  /// Panel section for live channels.
  ///
  /// In en, this message translates to:
  /// **'Live TV'**
  String get liveTv;

  /// Panel section for VOD movies.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get movies;

  /// Panel section for series.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get series;

  /// Panel section for favorite content.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// Panel section for application settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Shown when no EPG information is available for a channel.
  ///
  /// In en, this message translates to:
  /// **'No program information'**
  String get epgNoProgram;

  /// Placeholder text of the search field.
  ///
  /// In en, this message translates to:
  /// **'Search channels, movies...'**
  String get searchPlaceholder;

  /// Player option to select the audio track.
  ///
  /// In en, this message translates to:
  /// **'Audio Track'**
  String get audioTrack;

  /// Player option to select subtitles.
  ///
  /// In en, this message translates to:
  /// **'Subtitles'**
  String get subtitles;

  /// Shown when playback fails and a retry is attempted.
  ///
  /// In en, this message translates to:
  /// **'Playback error. Retrying...'**
  String get streamError;

  /// Label of the language selector.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;
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
