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
  String get liveTv => 'Live TV';

  @override
  String get movies => 'Movies';

  @override
  String get series => 'Series';

  @override
  String get favorites => 'Favorites';

  @override
  String get settings => 'Settings';

  @override
  String get epgNoProgram => 'No program information available';

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
