// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Kylora';

  @override
  String get loginTitle => 'Connect to IPTV';

  @override
  String get serverUrl => 'Server URL';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get loginButton => 'Sign In';

  @override
  String get loginErrorInvalidCredentials => 'Invalid URL or credentials';

  @override
  String get loginErrorNetwork =>
      'Could not connect to the server. Check the URL and your connection.';

  @override
  String get loginErrorUnknown => 'Unexpected error. Try again.';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationInvalidUrl =>
      'Enter a valid URL (e.g. http://server:8080)';

  @override
  String get signOut => 'Sign out';

  @override
  String get accountStatus => 'Account status';

  @override
  String get accountActive => 'Active';

  @override
  String get accountExpired => 'Expired';

  @override
  String accountExpiresOn(String date) {
    return 'Expires on $date';
  }

  @override
  String accountConnections(String active, String max) {
    return 'Connections: $active/$max';
  }

  @override
  String get liveTv => 'Live TV';

  @override
  String get allCategories => 'All';

  @override
  String get noChannels => 'No channels in this category';

  @override
  String get liveLoadError =>
      'Could not load the live catalog. Check your connection and try again.';

  @override
  String get retry => 'Retry';

  @override
  String get movies => 'Movies';

  @override
  String get series => 'Series';

  @override
  String get favorites => 'Favorites';

  @override
  String get settings => 'Settings';

  @override
  String get epgNoProgram => 'No program information';

  @override
  String get searchPlaceholder => 'Search channels, movies...';

  @override
  String get audioTrack => 'Audio Track';

  @override
  String get subtitles => 'Subtitles';

  @override
  String get streamError => 'Playback error. Retrying...';

  @override
  String get language => 'Language';
}
