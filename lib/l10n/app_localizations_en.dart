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
  String get loginSourceXtream => 'Xtream';

  @override
  String get loginSourceM3u => 'M3U/XMLTV';

  @override
  String get m3uDisplayName => 'Name (optional)';

  @override
  String get m3uPlaylistUrl => 'M3U playlist URL';

  @override
  String get m3uXmltvUrl => 'XMLTV EPG URL (optional)';

  @override
  String get loginErrorM3uParse =>
      'Could not parse the M3U playlist. Check the URL.';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationInvalidUrl =>
      'Enter a valid URL (e.g. http://server:8080)';

  @override
  String get signOut => 'Sign out';

  @override
  String get changeAccount => 'Change account';

  @override
  String get fullscreen => 'Fullscreen';

  @override
  String get exitFullscreen => 'Exit fullscreen';

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
  String get addedToFavorites => 'Added to favorites';

  @override
  String get removedFromFavorites => 'Removed from favorites';

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
  String get settingsSectionAccount => 'Account';

  @override
  String get settingsSectionCatalog => 'Catalog';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsSectionSecurity => 'Security';

  @override
  String get accountSource => 'Source';

  @override
  String get accountExpiration => 'Expiration';

  @override
  String get accountConnectionsLabel => 'Connections';

  @override
  String get accountXmltvPresent => 'Configured';

  @override
  String get accountXmltvMissing => 'Not configured';

  @override
  String get refreshCatalog => 'Refresh catalog';

  @override
  String get refreshCatalogDescription =>
      'Reloads channels, movies and series from the provider.';

  @override
  String get refreshCatalogSuccess => 'Catalog updated successfully';

  @override
  String get refreshCatalogFailure =>
      'Could not update the catalog. Check your connection.';

  @override
  String get clearCache => 'Clear cache';

  @override
  String get clearCacheConfirm =>
      'The local cache (saved channels) will be deleted. They will be downloaded again next time.';

  @override
  String get clearCacheSuccess => 'Cache cleared';

  @override
  String get localeSystem => 'System language';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'French';

  @override
  String get languageGerman => 'German';

  @override
  String get languageItalian => 'Italian';

  @override
  String get languagePortuguese => 'Portuguese';

  @override
  String get themeNocturne => 'Nocturne';

  @override
  String get themeExpressive => 'Expressive';

  @override
  String get themePacotis => 'Pacotis';

  @override
  String get themeCanvas => 'Canvas';

  @override
  String get pinCode => 'PIN code';

  @override
  String get settingsSectionSupport => 'Support';

  @override
  String get donation => 'Donate via PayPal';

  @override
  String get donationDescription =>
      'Support Kylora development with a voluntary donation.';

  @override
  String get donationOpenError => 'Could not open the donation link';

  @override
  String get contact => 'Contact by email';

  @override
  String get contactDescription =>
      'Send a message to contact@fmartinezgarcia.com.';

  @override
  String get contactOpenError => 'Could not open the email client';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get epgNoProgram => 'No program information';

  @override
  String get epgLoadError => 'Could not load the program guide';

  @override
  String get epgGuide => 'Program guide';

  @override
  String get nowEpg => 'Now';

  @override
  String get nextEpg => 'Next';

  @override
  String get close => 'Close';

  @override
  String get searchPlaceholder => 'Search channels, movies...';

  @override
  String get recentlyAdded => 'Recently added';

  @override
  String get continueWatchingSection => 'Continue watching';

  @override
  String get audioTrack => 'Audio Track';

  @override
  String get subtitles => 'Subtitles';

  @override
  String get streamError => 'Playback error. Retrying...';

  @override
  String get nowPlaying => 'Now playing';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get vodLoadError =>
      'Could not load the movie catalog. Check your connection and try again.';

  @override
  String get noMovies => 'No movies in this category';

  @override
  String get searchNoResults => 'No results found for your search';

  @override
  String get rating => 'Rating';

  @override
  String get seriesLoadError =>
      'Could not load the series catalog. Check your connection and try again.';

  @override
  String get noSeries => 'No series in this category';

  @override
  String get seriesDetailLoadError =>
      'Could not load the series episodes. Check your connection and try again.';

  @override
  String get season => 'Season';

  @override
  String get language => 'Language';

  @override
  String get history => 'History';

  @override
  String get noFavorites => 'No favorites yet';

  @override
  String get favoritesLoadError => 'Could not load favorites';

  @override
  String get noHistory => 'No playback history';

  @override
  String get clearHistory => 'Clear history';

  @override
  String get clearHistoryConfirm =>
      'Are you sure you want to delete all history? This action cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get historyLoadError => 'Could not load history';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours h ago';
  }

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }
}
