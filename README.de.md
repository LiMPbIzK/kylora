# Kylora

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Plattformen](https://img.shields.io/badge/Plattformen-Android%20%7C%20Android%20TV%20%7C%20Windows-blue)](https://github.com)
[![Linux](https://img.shields.io/badge/Linux-Demn%C3%A4chst-lightgrey?logo=linux&logoColor=white)](https://github.com)
[![macOS](https://img.shields.io/badge/macOS-Demn%C3%A4chst-lightgrey?logo=apple&logoColor=white)](https://github.com)
[![Engine](https://img.shields.io/badge/Video--Engine-media__kit%20(libmpv)-E040FB)](https://github.com/media-kit/media-kit)
[![CI](https://img.shields.io/badge/CI-GitHub%20Actions-brightgreen)](https://github.com)
[![Lizenz](https://img.shields.io/badge/Lizenz-MIT-green.svg)](LICENSE)

> 🌐 [Español](README.md) · [English](README.en.md) · [Français](README.fr.md) · **Deutsch** · [Italiano](README.it.md) · [Português](README.pt.md)

**Kylora** ist ein Local-First-IPTV-Client für Android-Mobilgeräte, Android TV/Google TV, Fire TV und Windows. Er ist auf schnelles Zappen, komfortable Fernbedienungsnavigation und flüssige Wiedergabe in HD, FHD und 4K ausgelegt – ohne eigenen Backend-Dienst, Telemetrie oder Cloud-Dienste.

## Funktionen

- **Xtream-Codes- und M3U/XMLTV-Quellen** über denselben Repository-Vertrag.
- **Android TV als Hauptziel:** vollständige D-Pad-Navigation, Leanback, Kontextmenüs, Titel-Laufschrift und fernbedienungsfreundlicher Programmführer.
- **4K/UHD-Wiedergabe:** `media_kit`/libmpv mit `mediacodec_embed` und `hwdec=mediacodec` unter Android; Audio-/Untertitelspuren, Spurauswahl und eigenes OSD.
- **Mehrere Konten:** verschlüsselte Konten, Wechsel des aktiven Kontos, manuelle Einrichtung und Einrichtung per QR vom Telefon.
- **Anmeldung vom Telefon:** Der Login zeigt einen QR-Code, um sich mit einem gespeicherten Konto anzumelden oder Zugangsdaten im selben WLAN hinzuzufügen/zu bearbeiten.
- **Kontoverwaltung ohne Sitzung:** Auch wenn alle Konten abgelaufen sind, können Konten bearbeitet, hinzugefügt, gelöscht, bereinigt und erneut versucht werden.
- **Optionaler PIN** zum Schutz der Kontoverwaltung und des Fernzugriffs.
- **Sichtbare und sortierbare Kategorien pro Konto**, inklusive Favoritengruppen pro Kategorie.
- **Getrennte Bereiche TV, Filme, Serien und Radio**, mit globaler Suche und Fortsetzen.
- **EPG:** Jetzt/Als Nächstes, Tagesraster, Mehrkanal-Guide (bis zu 30 Sender pro Ansicht) und Erinnerungen in der App.
- **Catch-up/Timeshift** bei kompatiblen Xtream-Sendern.
- **VOD-/Serien-Cache pro Konto**. Große Kataloge werden direkt nach der API-Antwort angezeigt, während der Cache im Hintergrund vervollständigt wird.
- **100 % lokal:** Zugangsdaten in `flutter_secure_storage`, Katalog in SQLite/Drift. Kein eigener Server, keine Telemetrie.
- **Sechs Sprachen:** Spanisch, Englisch, Französisch, Deutsch, Italienisch und Portugiesisch, live in den Einstellungen umschaltbar.
- **Vier Themes:** Nocturne, Expressive, Pacotis und Canvas.

## Architektur

Clean Architecture in drei Schichten:

```text
presentation  →  Screens, Blocs und gemeinsame Widgets
domain        →  Entitäten und Repository-Verträge
data          →  Remote-/Local-Datenquellen, DTOs und Repositories
```

- Zustandsverwaltung mit `flutter_bloc`.
- Persistenz mit `drift`/SQLite, Geheimnisse mit `flutter_secure_storage`.
- Quellenunabhängiges Repository: Xtream und M3U implementieren `IptvRepository`.
- Schwere Playlist- und XMLTV-Verarbeitung in Isolates.

## Struktur

```text
lib/
├── app.dart                 # MaterialApp.router, i18n und Themes
├── main.dart                # App-Initialisierung
├── core/                    # Utilities, Theme, Wiedergabe und Erinnerungen
├── data/                    # Datenquellen, DTOs und Repositories
├── domain/                  # Entitäten und Verträge
├── l10n/                    # ARB-Übersetzungen
└── presentation/            # Screens, Blocs und Widgets
```

## Erste Schritte

### Voraussetzungen

- Flutter 3.x stable mit Dart 3.x.
- **Windows:** Visual Studio 2022 mit *Desktop development with C++*.
- **Android/TV:** Android SDK; `minSdk 23`, `compileSdk 37`.
- Linux/macOS ist nach v1.0.0 geplant.

### Build

```bash
# Windows
flutter build windows

# Android-Mobilgerät
flutter build apk --release

# Android TV / Fire TV
flutter build apk --release --target-platform android-arm64
```

Unter Windows steht außerdem das TV-Installationsskript bereit:

```powershell
.\scripts\build-install-tv-release.bat 192.168.0.42
```

### Starten

```bash
flutter run -d windows
flutter run -d <android-geräte-id>
```

## Konfiguration

1. **Xtream Codes:** Server-URL, Benutzername und Passwort.
2. **M3U/M3U8:** URL oder lokale Datei und optional XMLTV.

Konten werden verschlüsselt und nach Kontofingerabdruck getrennt gespeichert (Favoriten, Verlauf, Kategorien und Cache). Der Telefon-Import nutzt einen temporären lokalen HTTP-Server und ein Sitzungstoken; er funktioniert nur im selben WLAN. Der QR-Code enthält niemals Zugangsdaten.

Bei abgelaufenen Konten oder nicht erreichbaren Anbietern:

1. **Konten verwalten** im Login öffnen.
2. Zugangsdaten bearbeiten oder ein Konto hinzufügen.
3. Ohne Validierung speichern und später erneut versuchen.

## Internationalisierung

App und Dokumentation sind verfügbar in:

| Sprache | README |
| :--- | :--- |
| Español | [README.md](README.md) |
| English | [README.en.md](README.en.md) |
| Français | [README.fr.md](README.fr.md) |
| Deutsch | [README.de.md](README.de.md) |
| Italiano | [README.it.md](README.it.md) |
| Português | [README.pt.md](README.pt.md) |

Die App-Sprache kann in den Einstellungen festgelegt oder automatisch vom System übernommen werden.

## Roadmap

- [x] **M0–M8:** Grundlage, Xtream, Katalog, Player, VOD/Serien, EPG, Favoriten, M3U und Android TV.
- [x] **M9:** Einstellungen, Themes, mehrsprachige UI, mehrere Konten, Web-Import, Catch-up, globale Suche und funktionale v1.0.0.
- [x] **Post-M9:** Kategorien pro Konto, Mehrkanal-EPG, dediziertes Radio, QR-Fernanmeldung, Kontoverwaltung ohne Sitzung, optionaler PIN und VOD-/Serien-Cache im Hintergrund.
- [ ] **Echte Release-Signatur** und endgültige Entfernung der Entwicklungs-Zugangsdaten aus der öffentlichen Historie.
- [ ] **System-EPG-Benachrichtigungen** bei geschlossener App.
- [ ] **Vollständiger Mehrkanal-Guide:** mehr als 30 Sender, Paginierung und Kategorieauswahl.
- [ ] **M10:** Linux- (.deb/.AppImage) und macOS-Builds (.dmg), Notarisierung und CI pro System.

## Entwicklung

```bash
flutter analyze
flutter test
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
```

Commits folgen [Conventional Commits](https://www.conventionalcommits.org). Die CI führt bei jedem Push Analyse und Tests aus.

## Rechtlicher Hinweis

Kylora ist ausschließlich ein Media-Client. Es stellt keine Inhalte, Playlists oder Abonnements bereit, hostet oder verteilt sie. Du bist für die Nutzung von Inhalten, auf die du Zugriff hast, sowie für die Einhaltung von Gesetzen und Anbieterbedingungen verantwortlich. Kylora unterstützt keine DRM-geschützten Inhalte.

## Lizenz

Veröffentlicht unter der [MIT-Lizenz](LICENSE).
