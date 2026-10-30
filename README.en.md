# Kylora

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20Android%20TV%20%7C%20Windows-blue)](https://github.com)
[![Linux](https://img.shields.io/badge/Linux-Coming%20soon-lightgrey?logo=linux&logoColor=white)](https://github.com)
[![macOS](https://img.shields.io/badge/macOS-Coming%20soon-lightgrey?logo=apple&logoColor=white)](https://github.com)
[![Engine](https://img.shields.io/badge/Video%20Engine-media__kit%20(libmpv)-E040FB)](https://github.com/media-kit/media-kit)
[![CI](https://img.shields.io/badge/CI-GitHub%20Actions-brightgreen)](https://github.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> 🌐 [Español](README.md) · **English** · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português](README.pt.md)

**Kylora** is a local-first IPTV client for Android mobile, Android TV/Google TV, Fire TV and Windows. It is designed for fast zapping, comfortable remote-control navigation and smooth HD, FHD and 4K playback, with no custom backend, telemetry or cloud services.

## Features

- **Xtream Codes and M3U/XMLTV sources** behind the same repository contract.
- **Android TV as the primary target:** full D-Pad focus, Leanback, context menus, title marquee and a remote-friendly program guide.
- **4K/UHD playback:** `media_kit`/libmpv with `mediacodec_embed` and `hwdec=mediacodec` on Android; audio/subtitle tracks, track selection and a custom OSD.
- **Multi-account:** encrypted accounts, active-account switching, manual setup and phone setup through a QR code.
- **Phone login:** the login screen shows a QR code to sign in with a saved account or add/edit credentials from the same Wi-Fi network.
- **Account management without a session:** even when every account is expired, you can edit, add, remove, clean up and retry from the pre-login account manager.
- **Optional PIN** protecting account management and remote access.
- **Visible and ordered categories per account**, plus favorite groups per category.
- **Separate TV, Movies, Series and Radio sections**, with global search and continue watching.
- **EPG:** now/next, daily grid, multi-channel guide (up to 30 channels per view) and in-app reminders.
- **Catch-up/timeshift** on compatible Xtream channels.
- **Per-account VOD/series cache**. Large catalogs are displayed as soon as the API responds while the cache is completed in the background.
- **100% local:** credentials in `flutter_secure_storage` and catalog data in SQLite/Drift. No custom server and no telemetry.
- **Six languages:** Spanish, English, French, German, Italian and Portuguese, switchable live from Settings.
- **Four themes:** Nocturne, Expressive, Pacotis and Canvas.

## Architecture

Clean Architecture in three layers:

```text
presentation  →  screens, blocs and shared widgets
domain        →  entities and repository contracts
data          →  remote/local datasources, DTOs and repositories
```

- State management with `flutter_bloc`.
- Persistence with `drift`/SQLite and secrets with `flutter_secure_storage`.
- Source-agnostic repository: Xtream and M3U implement `IptvRepository`.
- Heavy playlist and XMLTV parsing runs in isolates.

## Structure

```text
lib/
├── app.dart                 # MaterialApp.router, i18n and themes
├── main.dart                # App initialization
├── core/                    # Utilities, theme, playback and reminders
├── data/                    # Datasources, DTOs and repositories
├── domain/                  # Entities and contracts
├── l10n/                    # ARB translations
└── presentation/            # Screens, blocs and widgets
```

## Getting started

### Requirements

- Flutter 3.x stable with Dart 3.x.
- **Windows:** Visual Studio 2022 with *Desktop development with C++*.
- **Android/TV:** Android SDK; `minSdk 23`, `compileSdk 37`.
- Linux/macOS support is planned after v1.0.0.

### Build

```bash
# Windows
flutter build windows

# Android mobile
flutter build apk --release

# Android TV / Fire TV
flutter build apk --release --target-platform android-arm64
```

On Windows, the TV install script is also available:

```powershell
.\scripts\build-install-tv-release.bat 192.168.0.42
```

### Run

```bash
flutter run -d windows
flutter run -d <android-device-id>
```

## Configuration

1. **Xtream Codes:** server URL, username and password.
2. **M3U/M3U8:** URL or local file and, optionally, XMLTV.

Accounts are encrypted and isolated by account fingerprint (favorites, history, categories and cache). Phone import uses a temporary local HTTP server and a session token; it only works on the same Wi-Fi network. The QR code never contains credentials.

For expired accounts or unavailable providers:

1. Open **Manage accounts** from the login screen.
2. Edit credentials or add a new account.
3. Save without validation and retry when the provider responds.

## Internationalization

The app and documentation are available in:

| Language | README |
| :--- | :--- |
| Español | [README.md](README.md) |
| English | [README.en.md](README.en.md) |
| Français | [README.fr.md](README.fr.md) |
| Deutsch | [README.de.md](README.de.md) |
| Italiano | [README.it.md](README.it.md) |
| Português | [README.pt.md](README.pt.md) |

The app language can be fixed in Settings or left automatic based on the system.

## Roadmap

- [x] **M0–M8:** foundation, Xtream, catalog, player, VOD/series, EPG, favorites, M3U and Android TV.
- [x] **M9:** settings, themes, multilingual UI, multi-account, web import, catch-up, global search and a functional v1.0.0 release.
- [x] **Post-M9:** per-account categories, multi-channel EPG, dedicated radio, QR remote login, account management without a session, optional PIN and background VOD/series caching.
- [ ] **Real release signing** and definitive removal of development credentials from public history.
- [ ] **System EPG notifications** while the app is closed.
- [ ] **Full multi-channel guide:** more than 30 channels, pagination and category selection.
- [ ] **M10:** Linux (.deb/.AppImage) and macOS (.dmg) builds, notarization and per-OS CI.

## Development

```bash
flutter analyze
flutter test
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
```

Commits follow [Conventional Commits](https://www.conventionalcommits.org). CI runs analysis and tests on every push.

## Legal notice

Kylora is only a media client. It does not provide, host or distribute content, playlists or subscriptions. You are responsible for using content you have the right to access and for complying with the law and your provider's terms. Kylora does not support DRM-protected content.

## License

Distributed under the [MIT License](LICENSE).
