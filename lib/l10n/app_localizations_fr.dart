// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Kylora';

  @override
  String get loginTitle => 'Se connecter à l\'IPTV';

  @override
  String get serverUrl => 'URL du serveur';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get password => 'Mot de passe';

  @override
  String get loginButton => 'Se connecter';

  @override
  String get loginErrorInvalidCredentials => 'URL ou identifiants invalides';

  @override
  String get loginErrorNetwork =>
      'Impossible de se connecter au serveur. Vérifie l\'URL et ta connexion.';

  @override
  String get loginErrorUnknown => 'Erreur inattendue. Réessaie.';

  @override
  String get loginSourceXtream => 'Xtream';

  @override
  String get loginSourceM3u => 'M3U/XMLTV';

  @override
  String get m3uDisplayName => 'Nom (optionnel)';

  @override
  String get m3uPlaylistUrl => 'URL de la liste M3U';

  @override
  String get m3uXmltvUrl => 'URL de l\'EPG XMLTV (optionnel)';

  @override
  String get loginErrorM3uParse =>
      'Impossible de lire la liste M3U. Vérifie l\'URL.';

  @override
  String get validationRequired => 'Ce champ est obligatoire';

  @override
  String get validationInvalidUrl =>
      'Saisis une URL valide (ex. http://serveur:8080)';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get changeAccount => 'Changer de compte';

  @override
  String get addAccount => 'Ajouter un compte';

  @override
  String get addAccountFromPhone => 'Ajouter depuis le téléphone';

  @override
  String get webImportInstructions =>
      'Scannez le QR avec un téléphone connecté au même Wi-Fi. Vous pouvez aussi ouvrir l\'adresse dans un navigateur.';

  @override
  String get webImportStarting => 'Démarrage du serveur local…';

  @override
  String get webImportError =>
      'Impossible de démarrer le serveur local. Vérifiez que la TV et le téléphone sont sur le même Wi-Fi.';

  @override
  String get webImportLocalOnly =>
      'Réseau local uniquement : sans Internet ni HTTPS. L\'hôte, l\'utilisateur et le mot de passe ne peuvent pas être modifiés depuis le web ; seulement l\'étiquette ou la suppression du compte.';

  @override
  String get playFromStart => 'Lire depuis le début';

  @override
  String get catchupUnavailable =>
      'Ce programme n\'est pas disponible en catch-up.';

  @override
  String get selectAccount => 'Sélectionner un compte';

  @override
  String get fullscreen => 'Plein écran';

  @override
  String get exitFullscreen => 'Quitter le plein écran';

  @override
  String get accountStatus => 'État du compte';

  @override
  String get accountActive => 'Active';

  @override
  String get accountExpired => 'Expirée';

  @override
  String accountExpiresOn(String date) {
    return 'Expire le $date';
  }

  @override
  String accountConnections(String active, String max) {
    return 'Connexions : $active/$max';
  }

  @override
  String get liveTv => 'Télévision en Direct';

  @override
  String get radio => 'Radio';

  @override
  String get allCategories => 'Toutes';

  @override
  String get addedToFavorites => 'Ajouté aux favoris';

  @override
  String get removedFromFavorites => 'Retiré des favoris';

  @override
  String get noChannels => 'Aucune chaîne dans cette catégorie';

  @override
  String get liveLoadError =>
      'Impossible de charger le catalogue en direct. Vérifie ta connexion et réessaie.';

  @override
  String get retry => 'Réessayer';

  @override
  String get movies => 'Films';

  @override
  String get series => 'Séries';

  @override
  String get favorites => 'Favoris';

  @override
  String get settings => 'Réglages';

  @override
  String get clock => 'Horloge';

  @override
  String get clockFormat24h => '24 heures';

  @override
  String get clockFormat12h => '12 heures';

  @override
  String endsAt(String time) {
    return 'Se termine à $time';
  }

  @override
  String get viewDetails => 'Voir la fiche';

  @override
  String get settingsSectionAccount => 'Compte';

  @override
  String get settingsSectionCatalog => 'Catalogue';

  @override
  String get settingsSectionAppearance => 'Apparence';

  @override
  String get settingsSectionSecurity => 'Sécurité';

  @override
  String get accountSource => 'Source';

  @override
  String get accountExpiration => 'Expiration';

  @override
  String get accountConnectionsLabel => 'Connexions';

  @override
  String get accountXmltvPresent => 'Configuré';

  @override
  String get accountXmltvMissing => 'Non configuré';

  @override
  String get refreshCatalog => 'Actualiser le catalogue';

  @override
  String get refreshCatalogDescription =>
      'Recharge chaînes, films et séries depuis le fournisseur.';

  @override
  String get refreshCatalogSuccess => 'Catalogue mis à jour avec succès';

  @override
  String get refreshCatalogFailure =>
      'Impossible de mettre à jour le catalogue. Vérifie ta connexion.';

  @override
  String get clearCache => 'Vider le cache';

  @override
  String get clearCacheConfirm =>
      'Le cache local (chaînes enregistrées) sera supprimé. Elles seront redownloadées la prochaine fois.';

  @override
  String get clearCacheSuccess => 'Cache vidé';

  @override
  String get localeSystem => 'Langue du système';

  @override
  String get languageSpanish => 'Espagnol';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageGerman => 'Allemand';

  @override
  String get languageItalian => 'Italien';

  @override
  String get languagePortuguese => 'Portugais';

  @override
  String get themeNocturne => 'Nocturne';

  @override
  String get themeExpressive => 'Expressive';

  @override
  String get themePacotis => 'Pacotis';

  @override
  String get themeCanvas => 'Canvas';

  @override
  String get pinCode => 'Code PIN';

  @override
  String get settingsSectionSupport => 'Assistance';

  @override
  String get donation => 'Faire un don via PayPal';

  @override
  String get donationDescription =>
      'Soutiens le développement de Kylora avec un don volontaire.';

  @override
  String get donationOpenError => 'Impossible d\'ouvrir le lien de don';

  @override
  String get contact => 'Contacter par e-mail';

  @override
  String get contactDescription =>
      'Envoie un message à contact@fmartinezgarcia.com.';

  @override
  String get contactOpenError => 'Impossible d\'ouvrir le client e-mail';

  @override
  String get comingSoon => 'Bientôt disponible';

  @override
  String get epgNoProgram => 'Aucune information de programmation';

  @override
  String get epgLoadError => 'Impossible de charger le guide de programmation';

  @override
  String get epgGuide => 'Guide de programmation';

  @override
  String get nowEpg => 'Maintenant';

  @override
  String get nextEpg => 'Suivant';

  @override
  String get close => 'Fermer';

  @override
  String get exitAppTitle => 'Quitter Kylora ?';

  @override
  String get exitAppConfirm => 'Êtes-vous sûr de vouloir quitter Kylora ?';

  @override
  String get exitApp => 'Quitter';

  @override
  String get searchPlaceholder => 'Rechercher chaînes, films...';

  @override
  String get clearSearch => 'Effacer la recherche';

  @override
  String get recentlyAdded => 'Récemment ajouté';

  @override
  String get continueWatchingSection => 'Reprendre la lecture';

  @override
  String get removeResumeTitle => 'Supprimer la visualisation';

  @override
  String get removeResumeConfirm =>
      'Voulez-vous supprimer cette visualisation récente ? Vous ne pourrez plus la reprendre d\'ici.';

  @override
  String get removeResumeConfirmButton => 'Supprimer';

  @override
  String get audioTrack => 'Piste audio';

  @override
  String get settingsSectionPlayback => 'Lecture';

  @override
  String get audioLanguage => 'Langue audio';

  @override
  String get audioLanguageAuto => 'Langue de l\'application';

  @override
  String get subtitlesOff => 'Désactivés';

  @override
  String get subtitlesAutomatic => 'Automatiques (langue de l\'app)';

  @override
  String get subtitles => 'Sous-titres';

  @override
  String get streamError => 'Erreur de lecture. Nouvelle tentative...';

  @override
  String get nowPlaying => 'Lecture en cours';

  @override
  String get play => 'Lire';

  @override
  String get pause => 'Pause';

  @override
  String get vodLoadError =>
      'Impossible de charger le catalogue de films. Vérifie ta connexion et réessaie.';

  @override
  String get noMovies => 'Aucun film dans cette catégorie';

  @override
  String get searchNoResults => 'Aucun résultat pour ta recherche';

  @override
  String get searchLoadError =>
      'Impossible de charger la recherche. Vérifie la connexion.';

  @override
  String get rating => 'Note';

  @override
  String get seriesLoadError =>
      'Impossible de charger le catalogue de séries. Vérifie ta connexion et réessaie.';

  @override
  String get noSeries => 'Aucune série dans cette catégorie';

  @override
  String get seriesDetailLoadError =>
      'Impossible de charger les épisodes de la série. Vérifie ta connexion et réessaie.';

  @override
  String get season => 'Saison';

  @override
  String get language => 'Langue';

  @override
  String get history => 'Historique';

  @override
  String get noFavorites => 'Tu n\'as pas encore de favoris';

  @override
  String get favoritesLoadError => 'Impossible de charger les favoris';

  @override
  String get noHistory => 'Aucun historique de lecture';

  @override
  String get clearHistory => 'Vider l\'historique';

  @override
  String get clearHistoryConfirm =>
      'Veux-tu vraiment supprimer tout l\'historique ? Cette action est irréversible.';

  @override
  String get cancel => 'Annuler';

  @override
  String get historyLoadError => 'Impossible de charger l\'historique';

  @override
  String get justNow => 'À l\'instant';

  @override
  String minutesAgo(int minutes) {
    return 'Il y a $minutes min';
  }

  @override
  String hoursAgo(int hours) {
    return 'Il y a $hours h';
  }

  @override
  String daysAgo(int days) {
    return 'Il y a $days jours';
  }
}
