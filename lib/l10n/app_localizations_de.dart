// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Kylora';

  @override
  String get loginTitle => 'Mit IPTV verbinden';

  @override
  String get serverUrl => 'Server-URL';

  @override
  String get username => 'Benutzername';

  @override
  String get password => 'Passwort';

  @override
  String get loginButton => 'Anmelden';

  @override
  String get loginErrorInvalidCredentials => 'Ungültige URL oder Anmeldedaten';

  @override
  String get loginErrorNetwork =>
      'Keine Verbindung zum Server möglich. Prüfe die URL und deine Verbindung.';

  @override
  String get loginErrorUnknown => 'Unerwarteter Fehler. Versuche es erneut.';

  @override
  String get loginSourceXtream => 'Xtream';

  @override
  String get loginSourceM3u => 'M3U/XMLTV';

  @override
  String get m3uDisplayName => 'Name (optional)';

  @override
  String get m3uPlaylistUrl => 'M3U-Listen-URL';

  @override
  String get m3uXmltvUrl => 'XMLTV-EPG-URL (optional)';

  @override
  String get loginErrorM3uParse =>
      'Die M3U-Liste konnte nicht gelesen werden. Prüfe die URL.';

  @override
  String get validationRequired => 'Dieses Feld ist erforderlich';

  @override
  String get validationInvalidUrl =>
      'Gib eine gültige URL ein (z. B. http://server:8080)';

  @override
  String get signOut => 'Abmelden';

  @override
  String get changeAccount => 'Konto wechseln';

  @override
  String get fullscreen => 'Vollbild';

  @override
  String get exitFullscreen => 'Vollbild verlassen';

  @override
  String get accountStatus => 'Kontostatus';

  @override
  String get accountActive => 'Aktiv';

  @override
  String get accountExpired => 'Abgelaufen';

  @override
  String accountExpiresOn(String date) {
    return 'Läuft am $date ab';
  }

  @override
  String accountConnections(String active, String max) {
    return 'Verbindungen: $active/$max';
  }

  @override
  String get liveTv => 'Live-TV';

  @override
  String get allCategories => 'Alle';

  @override
  String get addedToFavorites => 'Zu Favoriten hinzugefügt';

  @override
  String get removedFromFavorites => 'Aus Favoriten entfernt';

  @override
  String get noChannels => 'Keine Kanäle in dieser Kategorie';

  @override
  String get liveLoadError =>
      'Der Live-Katalog konnte nicht geladen werden. Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get movies => 'Filme';

  @override
  String get series => 'Serien';

  @override
  String get favorites => 'Favoriten';

  @override
  String get settings => 'Einstellungen';

  @override
  String get settingsSectionAccount => 'Konto';

  @override
  String get settingsSectionCatalog => 'Katalog';

  @override
  String get settingsSectionAppearance => 'Erscheinungsbild';

  @override
  String get settingsSectionSecurity => 'Sicherheit';

  @override
  String get accountSource => 'Quelle';

  @override
  String get accountExpiration => 'Ablauf';

  @override
  String get accountConnectionsLabel => 'Verbindungen';

  @override
  String get accountXmltvPresent => 'Konfiguriert';

  @override
  String get accountXmltvMissing => 'Nicht konfiguriert';

  @override
  String get refreshCatalog => 'Katalog aktualisieren';

  @override
  String get refreshCatalogDescription =>
      'Lädt Kanäle, Filme und Serien vom Anbieter neu.';

  @override
  String get refreshCatalogSuccess => 'Katalog erfolgreich aktualisiert';

  @override
  String get refreshCatalogFailure =>
      'Der Katalog konnte nicht aktualisiert werden. Prüfe deine Verbindung.';

  @override
  String get clearCache => 'Cache leeren';

  @override
  String get clearCacheConfirm =>
      'Der lokale Cache (gespeicherte Kanäle) wird gelöscht. Sie werden beim nächsten Mal erneut heruntergeladen.';

  @override
  String get clearCacheSuccess => 'Cache geleert';

  @override
  String get localeSystem => 'Systemsprache';

  @override
  String get languageSpanish => 'Spanisch';

  @override
  String get languageEnglish => 'Englisch';

  @override
  String get languageFrench => 'Französisch';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageItalian => 'Italienisch';

  @override
  String get languagePortuguese => 'Portugiesisch';

  @override
  String get themeNocturne => 'Nocturne';

  @override
  String get themeExpressive => 'Expressive';

  @override
  String get themePacotis => 'Pacotis';

  @override
  String get themeCanvas => 'Canvas';

  @override
  String get pinCode => 'PIN-Code';

  @override
  String get settingsSectionSupport => 'Unterstützung';

  @override
  String get donation => 'Mit PayPal spenden';

  @override
  String get donationDescription =>
      'Unterstütze die Entwicklung von Kylora mit einer freiwilligen Spende.';

  @override
  String get donationOpenError =>
      'Der Spendenlink konnte nicht geöffnet werden';

  @override
  String get comingSoon => 'Bald verfügbar';

  @override
  String get epgNoProgram => 'Keine Programminformationen';

  @override
  String get epgLoadError => 'Der Programmführer konnte nicht geladen werden';

  @override
  String get epgGuide => 'Programmführer';

  @override
  String get nowEpg => 'Jetzt';

  @override
  String get nextEpg => 'Als Nächstes';

  @override
  String get close => 'Schließen';

  @override
  String get searchPlaceholder => 'Kanäle, Filme suchen...';

  @override
  String get audioTrack => 'Audiospur';

  @override
  String get subtitles => 'Untertitel';

  @override
  String get streamError => 'Wiedergabefehler. Neuer Versuch...';

  @override
  String get nowPlaying => 'Wird abgespielt';

  @override
  String get play => 'Abspielen';

  @override
  String get pause => 'Pause';

  @override
  String get vodLoadError =>
      'Der Filmkatalog konnte nicht geladen werden. Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get noMovies => 'Keine Filme in dieser Kategorie';

  @override
  String get searchNoResults => 'Keine Ergebnisse für deine Suche';

  @override
  String get rating => 'Bewertung';

  @override
  String get seriesLoadError =>
      'Der Serienkatalog konnte nicht geladen werden. Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get noSeries => 'Keine Serien in dieser Kategorie';

  @override
  String get seriesDetailLoadError =>
      'Die Episoden der Serie konnten nicht geladen werden. Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get season => 'Staffel';

  @override
  String get language => 'Sprache';

  @override
  String get history => 'Verlauf';

  @override
  String get noFavorites => 'Du hast noch keine Favoriten';

  @override
  String get favoritesLoadError => 'Favoriten konnten nicht geladen werden';

  @override
  String get noHistory => 'Kein Wiedergabeverlauf';

  @override
  String get clearHistory => 'Verlauf leeren';

  @override
  String get clearHistoryConfirm =>
      'Möchtest du wirklich den gesamten Verlauf löschen? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get historyLoadError => 'Verlauf konnte nicht geladen werden';

  @override
  String get justNow => 'Gerade eben';

  @override
  String minutesAgo(int minutes) {
    return 'Vor $minutes Min.';
  }

  @override
  String hoursAgo(int hours) {
    return 'Vor $hours Std.';
  }

  @override
  String daysAgo(int days) {
    return 'Vor $days Tagen';
  }
}
