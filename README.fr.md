# Kylora

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Plateformes](https://img.shields.io/badge/Plateformes-Android%20%7C%20Android%20TV%20%7C%20Windows-blue)](https://github.com)
[![Linux](https://img.shields.io/badge/Linux-Bient%C3%B4t-lightgrey?logo=linux&logoColor=white)](https://github.com)
[![macOS](https://img.shields.io/badge/macOS-Bient%C3%B4t-lightgrey?logo=apple&logoColor=white)](https://github.com)
[![Moteur](https://img.shields.io/badge/Moteur%20vid%C3%A9o-media__kit%20(libmpv)-E040FB)](https://github.com/media-kit/media-kit)
[![CI](https://img.shields.io/badge/CI-GitHub%20Actions-brightgreen)](https://github.com)
[![Licence](https://img.shields.io/badge/Licence-MIT-green.svg)](LICENSE)

> 🌐 [Español](README.md) · [English](README.en.md) · **Français** · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português](README.pt.md)

**Kylora** est un client IPTV local-first pour Android mobile, Android TV/Google TV, Fire TV et Windows. Il est conçu pour un zapping rapide, une navigation confortable à la télécommande et une lecture fluide en HD, FHD et 4K, sans backend propriétaire, télémétrie ni services cloud.

## Fonctionnalités

- **Sources Xtream Codes et M3U/XMLTV** derrière le même contrat de dépôt.
- **Android TV comme cible principale :** navigation D-Pad complète, Leanback, menus contextuels, défilement des titres et guide utilisable à la télécommande.
- **Lecture 4K/UHD :** `media_kit`/libmpv avec `mediacodec_embed` et `hwdec=mediacodec` sous Android ; pistes audio/sous-titres, sélection de piste et OSD personnalisé.
- **Multi-compte :** comptes chiffrés, changement de compte actif, saisie manuelle et ajout depuis le téléphone par QR.
- **Connexion depuis le téléphone :** l'écran de connexion affiche un QR pour utiliser un compte enregistré ou ajouter/modifier des identifiants depuis le même Wi-Fi.
- **Gestion des comptes sans session :** même si tous les comptes sont expirés, il est possible de les modifier, d'en ajouter, d'en supprimer, de nettoyer et de réessayer depuis le gestionnaire pré-connexion.
- **PIN facultatif** protégeant la gestion des comptes et l'accès à distance.
- **Catégories visibles et ordonnées par compte**, avec groupes favoris par catégorie.
- **Sections TV, Films, Séries et Radio séparées**, avec recherche globale et reprise de lecture.
- **EPG :** maintenant/ensuite, grille quotidienne, guide multi-chaînes (jusqu'à 30 chaînes par vue) et rappels dans l'application.
- **Catch-up/timeshift** sur les chaînes Xtream compatibles.
- **Cache VOD/séries par compte**. Les grands catalogues s'affichent dès la réponse de l'API et le cache se complète en arrière-plan.
- **100 % local :** identifiants dans `flutter_secure_storage` et catalogue dans SQLite/Drift. Aucun serveur propriétaire, aucune télémétrie.
- **Six langues :** espagnol, anglais, français, allemand, italien et portugais, modifiables à chaud depuis les Réglages.
- **Quatre thèmes :** Nocturne, Expressive, Pacotis et Canvas.

## Architecture

Clean Architecture en trois couches :

```text
presentation  →  écrans, blocs et widgets partagés
domain        →  entités et contrats de dépôt
data          →  sources distantes/locales, DTO et dépôts
```

- Gestion d'état avec `flutter_bloc`.
- Persistance avec `drift`/SQLite et secrets avec `flutter_secure_storage`.
- Dépôt indépendant de la source : Xtream et M3U implémentent `IptvRepository`.
- Analyse des listes et XMLTV dans des isolates.

## Structure

```text
lib/
├── app.dart                 # MaterialApp.router, i18n et thèmes
├── main.dart                # Initialisation de l'application
├── core/                    # Utilitaires, thème, lecture et rappels
├── data/                    # Sources, DTO et dépôts
├── domain/                  # Entités et contrats
├── l10n/                    # Traductions ARB
└── presentation/            # Écrans, blocs et widgets
```

## Démarrage

### Prérequis

- Flutter 3.x stable avec Dart 3.x.
- **Windows :** Visual Studio 2022 avec *Desktop development with C++*.
- **Android/TV :** Android SDK ; `minSdk 23`, `compileSdk 37`.
- Linux/macOS est prévu après la v1.0.0.

### Compilation

```bash
# Windows
flutter build windows

# Android mobile
flutter build apk --release

# Android TV / Fire TV
flutter build apk --release --target-platform android-arm64
```

Sous Windows, le script d'installation TV est également disponible :

```powershell
.\scripts\build-install-tv-release.bat 192.168.0.42
```

### Exécution

```bash
flutter run -d windows
flutter run -d <id-appareil-android>
```

## Configuration

1. **Xtream Codes :** URL du serveur, utilisateur et mot de passe.
2. **M3U/M3U8 :** URL ou fichier local et, éventuellement, XMLTV.

Les comptes sont chiffrés et isolés par empreinte de compte (favoris, historique, catégories et cache). L'import depuis le téléphone utilise un serveur HTTP local temporaire et un jeton de session ; il ne fonctionne que sur le même réseau Wi-Fi. Le QR ne contient jamais les identifiants.

Pour les comptes expirés ou les fournisseurs indisponibles :

1. Ouvrir **Gérer les comptes** depuis la connexion.
2. Modifier les identifiants ou ajouter un compte.
3. Enregistrer sans validation et réessayer lorsque le fournisseur répond.

## Internationalisation

L'application et la documentation sont disponibles en :

| Langue | README |
| :--- | :--- |
| Español | [README.md](README.md) |
| English | [README.en.md](README.en.md) |
| Français | [README.fr.md](README.fr.md) |
| Deutsch | [README.de.md](README.de.md) |
| Italiano | [README.it.md](README.it.md) |
| Português | [README.pt.md](README.pt.md) |

La langue de l'application peut être fixée dans les Réglages ou laissée en automatique selon le système.

## Feuille de route

- [x] **M0–M8 :** fondation, Xtream, catalogue, lecteur, VOD/séries, EPG, favoris, M3U et Android TV.
- [x] **M9 :** réglages, thèmes, interface multilingue, multi-compte, import web, catch-up, recherche globale et version v1.0.0 fonctionnelle.
- [x] **Post-M9 :** catégories par compte, EPG multi-chaînes, radio dédiée, connexion à distance par QR, gestion des comptes sans session, PIN facultatif et cache VOD/séries en arrière-plan.
- [ ] **Signature de version réelle** et suppression définitive des identifiants de développement de l'historique public.
- [ ] **Notifications EPG système** avec l'application fermée.
- [ ] **Guide multi-chaînes complet :** plus de 30 chaînes, pagination et sélection de catégorie.
- [ ] **M10 :** versions Linux (.deb/.AppImage) et macOS (.dmg), notarisation et CI par système.

## Développement

```bash
flutter analyze
flutter test
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
```

Les commits suivent [Conventional Commits](https://www.conventionalcommits.org). La CI exécute l'analyse et les tests à chaque push.

## Avertissement légal

Kylora est uniquement un lecteur multimédia. Il ne fournit, n'héberge et ne distribue aucun contenu, aucune liste ni aucun abonnement. Vous êtes responsable de l'utilisation de contenus auxquels vous avez droit et du respect de la loi et des conditions de votre fournisseur. Kylora ne prend pas en charge les contenus protégés par DRM.

## Licence

Distribué sous [licence MIT](LICENSE).
