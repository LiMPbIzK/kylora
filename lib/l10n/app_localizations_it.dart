// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Kylora';

  @override
  String get loginTitle => 'Connettiti all\'IPTV';

  @override
  String get serverUrl => 'URL del server';

  @override
  String get username => 'Nome utente';

  @override
  String get password => 'Password';

  @override
  String get loginButton => 'Accedi';

  @override
  String get loginErrorInvalidCredentials => 'URL o credenziali non valide';

  @override
  String get loginErrorNetwork =>
      'Impossibile connettersi al server. Controlla l\'URL e la connessione.';

  @override
  String get loginErrorUnknown => 'Errore imprevisto. Riprova.';

  @override
  String get loginSourceXtream => 'Xtream';

  @override
  String get loginSourceM3u => 'M3U/XMLTV';

  @override
  String get m3uDisplayName => 'Nome (opzionale)';

  @override
  String get m3uPlaylistUrl => 'URL della lista M3U';

  @override
  String get m3uXmltvUrl => 'URL EPG XMLTV (opzionale)';

  @override
  String get loginErrorM3uParse =>
      'Impossibile leggere la lista M3U. Controlla l\'URL.';

  @override
  String get validationRequired => 'Questo campo è obbligatorio';

  @override
  String get validationInvalidUrl =>
      'Inserisci un URL valido (es. http://server:8080)';

  @override
  String get signOut => 'Disconnetti';

  @override
  String get changeAccount => 'Cambia account';

  @override
  String get addAccount => 'Aggiungi account';

  @override
  String get addAccountFromPhone => 'Aggiungi dal telefono';

  @override
  String get webImportInstructions =>
      'Scansiona il QR con un telefono connesso alla stessa Wi-Fi. Puoi anche aprire l\'indirizzo nel browser.';

  @override
  String get webImportStarting => 'Avvio del server locale…';

  @override
  String get webImportError =>
      'Impossibile avviare il server locale. Controlla che TV e telefono siano sulla stessa Wi-Fi.';

  @override
  String get webImportLocalOnly =>
      'Solo rete locale: niente Internet né HTTPS. Host, utente e password non si possono modificare dal web; solo l\'etichetta o l\'eliminazione dell\'account.';

  @override
  String get playFromStart => 'Riproduci dall\'inizio';

  @override
  String get catchupUnavailable =>
      'Questo programma non è disponibile in catch-up.';

  @override
  String get selectAccount => 'Seleziona account';

  @override
  String get fullscreen => 'Schermo intero';

  @override
  String get exitFullscreen => 'Esci da schermo intero';

  @override
  String get accountStatus => 'Stato dell\'account';

  @override
  String get accountActive => 'Attivo';

  @override
  String get accountExpired => 'Scaduto';

  @override
  String accountExpiresOn(String date) {
    return 'Scade il $date';
  }

  @override
  String accountConnections(String active, String max) {
    return 'Connessioni: $active/$max';
  }

  @override
  String get liveTv => 'TV in Diretta';

  @override
  String get radio => 'Radio';

  @override
  String get allCategories => 'Tutte';

  @override
  String get addedToFavorites => 'Aggiunto ai preferiti';

  @override
  String get removedFromFavorites => 'Rimosso dai preferiti';

  @override
  String get noChannels => 'Nessun canale in questa categoria';

  @override
  String get liveLoadError =>
      'Impossibile caricare il catalogo in diretta. Controlla la connessione e riprova.';

  @override
  String get retry => 'Riprova';

  @override
  String get movies => 'Film';

  @override
  String get series => 'Serie';

  @override
  String get favorites => 'Preferiti';

  @override
  String get manageCategories => 'Gestisci categorie';

  @override
  String get multiChannelGuide => 'Guida multi-canale';

  @override
  String get save => 'Salva';

  @override
  String get saveError => 'Impossibile salvare le modifiche';

  @override
  String get moveUp => 'Sposta su';

  @override
  String get moveDown => 'Sposta giù';

  @override
  String get settings => 'Impostazioni';

  @override
  String get clock => 'Orologio';

  @override
  String get clockFormat24h => '24 ore';

  @override
  String get clockFormat12h => '12 ore';

  @override
  String endsAt(String time) {
    return 'Termina alle $time';
  }

  @override
  String get viewDetails => 'Vedi scheda';

  @override
  String get settingsSectionAccount => 'Account';

  @override
  String get settingsSectionCatalog => 'Catalogo';

  @override
  String get settingsSectionAppearance => 'Aspetto';

  @override
  String get settingsSectionSecurity => 'Sicurezza';

  @override
  String get accountSource => 'Origine';

  @override
  String get accountExpiration => 'Scadenza';

  @override
  String get accountConnectionsLabel => 'Connessioni';

  @override
  String get accountXmltvPresent => 'Configurata';

  @override
  String get accountXmltvMissing => 'Non configurata';

  @override
  String get refreshCatalog => 'Aggiorna catalogo';

  @override
  String get refreshCatalogDescription =>
      'Ricarica canali, film e serie dal provider.';

  @override
  String get refreshCatalogSuccess => 'Catalogo aggiornato correttamente';

  @override
  String get refreshCatalogFailure =>
      'Impossibile aggiornare il catalogo. Controlla la connessione.';

  @override
  String get clearCache => 'Svuota cache';

  @override
  String get clearCacheConfirm =>
      'La cache locale (canali salvati) verrà eliminata. Verranno scaricati di nuovo la prossima volta.';

  @override
  String get clearCacheSuccess => 'Cache svuotata';

  @override
  String get localeSystem => 'Lingua di sistema';

  @override
  String get languageSpanish => 'Spagnolo';

  @override
  String get languageEnglish => 'Inglese';

  @override
  String get languageFrench => 'Francese';

  @override
  String get languageGerman => 'Tedesco';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languagePortuguese => 'Portoghese';

  @override
  String get themeNocturne => 'Nocturne';

  @override
  String get themeExpressive => 'Expressive';

  @override
  String get themePacotis => 'Pacotis';

  @override
  String get themeCanvas => 'Canvas';

  @override
  String get pinCode => 'Codice PIN';

  @override
  String get settingsSectionSupport => 'Supporto';

  @override
  String get donation => 'Dona tramite PayPal';

  @override
  String get donationDescription =>
      'Sostieni lo sviluppo di Kylora con una donazione volontaria.';

  @override
  String get donationOpenError => 'Impossibile aprire il link di donazione';

  @override
  String get contact => 'Contatta via email';

  @override
  String get contactDescription =>
      'Invia un messaggio a contact@fmartinezgarcia.com.';

  @override
  String get contactOpenError => 'Impossibile aprire il client di posta';

  @override
  String get comingSoon => 'Presto disponibile';

  @override
  String get epgNoProgram => 'Nessuna informazione sulla programmazione';

  @override
  String get epgLoadError =>
      'Impossibile caricare la guida alla programmazione';

  @override
  String get epgGuide => 'Guida alla programmazione';

  @override
  String get previous => 'Precedente';

  @override
  String get next => 'Successivo';

  @override
  String get today => 'Oggi';

  @override
  String get reminderSet => 'Promemoria attivato';

  @override
  String get reminderRemoved => 'Promemoria rimosso';

  @override
  String get reminderDueTitle => 'Promemoria';

  @override
  String get watchNow => 'Guarda ora';

  @override
  String get nowEpg => 'Ora';

  @override
  String get nextEpg => 'Prossimo';

  @override
  String get close => 'Chiudi';

  @override
  String get exitAppTitle => 'Uscire da Kylora?';

  @override
  String get exitAppConfirm => 'Vuoi davvero uscire da Kylora?';

  @override
  String get exitApp => 'Esci';

  @override
  String get searchPlaceholder => 'Cerca canali, film...';

  @override
  String get clearSearch => 'Cancella ricerca';

  @override
  String get recentlyAdded => 'Aggiunto di recente';

  @override
  String get continueWatchingSection => 'Continua a guardare';

  @override
  String get removeResumeTitle => 'Rimuovi visualizzazione';

  @override
  String get removeResumeConfirm =>
      'Vuoi rimuovere questa visualizzazione recente? Non potrai riprenderla da qui.';

  @override
  String get removeResumeConfirmButton => 'Rimuovi';

  @override
  String get audioTrack => 'Traccia audio';

  @override
  String get settingsSectionPlayback => 'Riproduzione';

  @override
  String get audioLanguage => 'Lingua audio';

  @override
  String get audioLanguageAuto => 'Lingua dell\'app';

  @override
  String get subtitlesOff => 'Disattivati';

  @override
  String get subtitlesAutomatic => 'Automatici (lingua dell\'app)';

  @override
  String get subtitles => 'Sottotitoli';

  @override
  String get streamError => 'Errore di riproduzione. Nuovo tentativo...';

  @override
  String get nowPlaying => 'In riproduzione';

  @override
  String get play => 'Riproduci';

  @override
  String get pause => 'Pausa';

  @override
  String get vodLoadError =>
      'Impossibile caricare il catalogo dei film. Controlla la connessione e riprova.';

  @override
  String get noMovies => 'Nessun film in questa categoria';

  @override
  String get searchNoResults => 'Nessun risultato per la tua ricerca';

  @override
  String get searchLoadError =>
      'Impossibile caricare la ricerca. Controlla la connessione.';

  @override
  String get rating => 'Valutazione';

  @override
  String get seriesLoadError =>
      'Impossibile caricare il catalogo delle serie. Controlla la connessione e riprova.';

  @override
  String get noSeries => 'Nessuna serie in questa categoria';

  @override
  String get seriesDetailLoadError =>
      'Impossibile caricare gli episodi della serie. Controlla la connessione e riprova.';

  @override
  String get season => 'Stagione';

  @override
  String get language => 'Lingua';

  @override
  String get favoriteGroups => 'Gruppi preferiti';

  @override
  String get addGroupToFavorites => 'Aggiungi gruppo ai preferiti';

  @override
  String get removeGroupFromFavorites => 'Rimuovi gruppo dai preferiti';

  @override
  String get groupFavoriteAdded => 'Gruppo aggiunto ai preferiti';

  @override
  String get groupFavoriteRemoved => 'Gruppo rimosso dai preferiti';

  @override
  String get history => 'Cronologia';

  @override
  String get noFavorites => 'Non hai ancora preferiti';

  @override
  String get favoritesLoadError => 'Impossibile caricare i preferiti';

  @override
  String get noHistory => 'Nessuna cronologia di riproduzione';

  @override
  String get clearHistory => 'Svuota cronologia';

  @override
  String get clearHistoryConfirm =>
      'Vuoi davvero eliminare tutta la cronologia? Questa azione non può essere annullata.';

  @override
  String get cancel => 'Annulla';

  @override
  String get historyLoadError => 'Impossibile caricare la cronologia';

  @override
  String get justNow => 'Adesso';

  @override
  String minutesAgo(int minutes) {
    return '$minutes min fa';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours h fa';
  }

  @override
  String daysAgo(int days) {
    return '$days giorni fa';
  }
}
