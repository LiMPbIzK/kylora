# Kylora 📺

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Android%20TV%20%7C%20Windows-blue)](https://github.com)
[![Linux](https://img.shields.io/badge/Linux-Coming%20soon-lightgrey?logo=linux&logoColor=white)](https://github.com)
[![macOS](https://img.shields.io/badge/macOS-Coming%20soon-lightgrey?logo=apple&logoColor=white)](https://github.com)
[![Engine](https://img.shields.io/badge/Video%20Engine-media__kit%20(libmpv)-E040FB)](https://github.com/media-kit/media-kit)
[![CI](https://img.shields.io/badge/CI-GitHub%20Actions-brightgreen)](https://github.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**Kylora** is a clean, local-first, and high-performance IPTV client designed for seamless playback across mobile devices, Android TV/Fire TV sticks, and Windows desktop. It focuses on low memory overhead, instant channel zapping, and a native leanback experience — no intermediary servers, no telemetry, no analytics.

> 🌐 **Spanish:** [README.md](README.md)

---

## ✨ Key Features

* **Multi-Source Support:** Direct compatibility with Xtream Codes API and static M3U/M3U8 playlists with XMLTV EPG.
* **100% Local & Private:** No custom backend, telemetry, or external databases. Your credentials and playlists stay strictly on your device.
* **Native Cross-Platform UI:** Tailored interface with responsive touch controls for mobile/tablet and full D-Pad focus management for TV remotes and keyboard navigation.
* **Hardware-Accelerated Engine:** Powered by `media_kit` (libmpv) for native MPEG-TS, HLS, and MKV stream demuxing with multi-track audio and embedded subtitle selection.
* **Smart Local Indexing:** Heavy playlist parsing executed in background isolates and indexed with Drift (SQLite) for instant search and categorization.
* **Multi-Language (i18n):** Native support for English, Spanish, French, German, Italian, and Portuguese.

---

## 🏗️ Architecture

Clean Architecture with a strict separation of concerns across three layers:

```
┌─────────────────────────────────────────────┐
│              presentation                   │
│   screens · blocs · shared widgets          │
├─────────────────────────────────────────────┤
│                  domain                     │
│   entities · repository contracts           │
├─────────────────────────────────────────────┤
│                   data                      │
│   datasources (remote/local) · repositories │
│   models (DTOs)                             │
└─────────────────────────────────────────────┘
```

* **State management:** `flutter_bloc` for predictable, traceable business logic.
* **Domain purity:** business rules live in the inner layer with zero framework dependencies.
* **Source-agnostic repository:** both Xtream and M3U implementations satisfy the same `IptvRepository` contract.

## 📁 Project Structure

```
lib/
├── main.dart                      # Global initialization (MediaKit, DB, BlocObserver)
├── app.dart                       # MaterialApp.router, i18n and themes
├── l10n/                          # ARB translation dictionaries
├── core/                          # Cross-cutting utilities
│   ├── constants/                 # Xtream endpoints, timeouts, user-agents
│   ├── network/                   # Centralized Dio client
│   ├── theme/                     # Colors, TV focus styles
│   └── utils/                     # M3U isolate parser, EPG date formatter
├── data/                          # External layer
│   ├── datasources/
│   │   ├── local/                 # Drift schema (Channels, Favorites, History), secure storage
│   │   └── remote/                # Xtream API client, M3U/XMLTV downloader
│   ├── models/                    # DTOs (auth, category, stream, EPG)
│   └── repositories/              # Xtream and M3U implementations
├── domain/                        # Pure business logic
│   ├── entities/                  # UserAccount, Category, StreamItem, EpgEntry
│   └── repositories/              # IptvRepository contract
└── presentation/                  # UI layer
    ├── blocs/                     # auth · live · vod · settings · player
    ├── shared_widgets/            # focusable items, error views, loaders
    └── screens/                   # login, dashboard, live, vod, settings, player
```

---

## 🚀 Getting Started

### Prerequisites

* [Flutter 3.x](https://docs.flutter.dev/get-started/install) (stable channel) with Dart 3.x
* **Windows:** Visual Studio 2022 with the *Desktop development with C++* workload (CMake toolchain)
* **Android / Android TV:** Android SDK (minSdk 23, compileSdk 37)

> **Linux & macOS** will be added after v1.0.0 (milestone M10): the codebase is cross-platform, they only require specific builds and packaging.

### Build

```bash
# Windows desktop
flutter build windows

# Android APK (mobile)
flutter build apk --release

# Android TV / Fire TV APK (leanback)
flutter build apk --release --target-platform android-arm64
```

### Run

```bash
flutter run -d windows
flutter run -d <android-device-id>
```

---

## ⚙️ Configuration

Kylora supports two subscription sources:

1. **Xtream Codes API** — enter your provider's server URL, username, and password.
2. **M3U/M3U8 playlist** — load a local file or remote URL, optionally paired with an XMLTV EPG source.

Credentials are stored encrypted via `flutter_secure_storage`; playlists are indexed locally in SQLite. Nothing ever leaves your device except the direct requests to your provider.

> ⚠️ **Cleartext traffic:** HTTP (non-SSL) streams are supported for providers without HTTPS. This is scoped via a network security configuration.

---

## 🌍 Internationalization

Built on `flutter_localizations` + `intl` with generated ARB files and automatic system-language detection.

| Locale | Status |
| :--- | :--- |
| English | ✅ |
| Spanish | ✅ |
| French | 🔜 Roadmap |
| German | 🔜 Roadmap |
| Italian | 🔜 Roadmap |
| Portuguese | 🔜 Roadmap |

---

## 🗺️ Roadmap

- [x] **M0 — Foundation:** project scaffold, dependencies, folder structure, i18n (en/es), theme, router
- [ ] **M1 — Xtream subscription:** login, secure storage, session persistence, account status
- [ ] **M2 — Live catalog:** Drift schema + indexing, categories, channel list with logos
- [ ] **M3 — Player:** media_kit integration, OSD controls, audio/subtitle tracks, retry handling
- [ ] **M4 — VOD & Series:** grids, detail views, series episodes
- [ ] **M5 — EPG:** now/next in channel list, full schedule view, XMLTV + Xtream short EPG
- [ ] **M6 — Favorites, history & search:** persistent favorites, playback history, instant search
- [ ] **M7 — M3U/XMLTV source:** source selector, background-isolate parsing, unified contract
- [ ] **M8 — Android TV / Fire TV:** D-Pad focus management, leanback banner, remote navigation
- [ ] **M9 — Settings & release:** language switcher, cache management, remaining locales, v1.0.0
- [ ] **M10 — Linux/macOS portability (post-v1.0.0):** desktop builds for Linux (.deb/.AppImage) and macOS (.dmg), notarization and per-OS CI — no logic changes (v1.1)

---

## 🛠️ Development

* **Commits:** [Conventional Commits](https://www.conventionalcommits.org) (`feat:`, `fix:`, `docs:`, `chore:`).
* **Lint & analyze:** `flutter analyze`
* **Tests:** `flutter test`
* **Code generation** (Drift/l10n): `dart run build_runner build --delete-conflicting-outputs`
* **CI:** GitHub Actions runs `flutter analyze` and `flutter test` on every push.

---

## ⚠️ Legal Disclaimer

Kylora is a media player **client** only. It does **not** provide, host, or distribute any content, streams, playlists, or subscriptions.

* You are responsible for any IPTV subscription or playlist you use, and for complying with your provider's terms of service and applicable copyright laws in your jurisdiction.
* Kylora does **not** support DRM-protected content.
* Streaming unauthorized content may be illegal in your country. Use Kylora only with content you own or have the right to access.

---

## 📄 License

Distributed under the [MIT License](LICENSE). See `LICENSE` for more information.
