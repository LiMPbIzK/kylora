# Kylora

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Piattaforme](https://img.shields.io/badge/Piattaforme-Android%20%7C%20Android%20TV%20%7C%20Windows-blue)](https://github.com)
[![Linux](https://img.shields.io/badge/Linux-In%20arrivo-lightgrey?logo=linux&logoColor=white)](https://github.com)
[![macOS](https://img.shields.io/badge/macOS-In%20arrivo-lightgrey?logo=apple&logoColor=white)](https://github.com)
[![Motore](https://img.shields.io/badge/Motore%20video-media__kit%20(libmpv)-E040FB)](https://github.com/media-kit/media-kit)
[![CI](https://img.shields.io/badge/CI-GitHub%20Actions-brightgreen)](https://github.com)
[![Licenza](https://img.shields.io/badge/Licenza-MIT-green.svg)](LICENSE)

> 🌐 [Español](README.md) · [English](README.en.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · **Italiano** · [Português](README.pt.md)

**Kylora** è un client IPTV local-first per Android mobile, Android TV/Google TV, Fire TV e Windows. È progettato per uno zapping rapido, una navigazione comoda con il telecomando e una riproduzione fluida in HD, FHD e 4K, senza backend proprietario, telemetria o servizi cloud.

## Funzionalità

- **Sorgenti Xtream Codes e M3U/XMLTV** con lo stesso contratto di repository.
- **Android TV come obiettivo principale:** navigazione D-Pad completa, Leanback, menu contestuali, scorrimento dei titoli e guida TV utilizzabile con il telecomando.
- **Riproduzione 4K/UHD:** `media_kit`/libmpv con `mediacodec_embed` e `hwdec=mediacodec` su Android; tracce audio/sottotitoli, selezione traccia e OSD personalizzato.
- **Multi-account:** account cifrati, cambio dell'account attivo, configurazione manuale e aggiunta dal telefono tramite QR.
- **Accesso dal telefono:** la schermata di login mostra un QR per accedere con un account salvato o aggiungere/modificare le credenziali dalla stessa Wi-Fi.
- **Gestione account senza sessione:** anche se tutti gli account sono scaduti, è possibile modificarli, aggiungerne, eliminarli, ripulirli e riprovare dal gestore pre-login.
- **PIN opzionale** per proteggere la gestione account e l'accesso remoto.
- **Categorie visibili e ordinabili per account**, con gruppi preferiti per categoria.
- **Sezioni TV, Film, Serie e Radio separate**, con ricerca globale e continua visione.
- **EPG:** ora/prossimo, griglia giornaliera, guida multi-canale (fino a 30 canali per vista) e promemoria nell'app.
- **Catch-up/timeshift** sui canali Xtream compatibili.
- **Cache VOD/serie per account**. I cataloghi grandi vengono mostrati appena risponde l'API mentre la cache viene completata in background.
- **100% locale:** credenziali in `flutter_secure_storage` e catalogo in SQLite/Drift. Nessun server proprietario, nessuna telemetria.
- **Sei lingue:** spagnolo, inglese, francese, tedesco, italiano e portoghese, modificabili a caldo dalle Impostazioni.
- **Quattro temi:** Nocturne, Expressive, Pacotis e Canvas.

## Architettura

Clean Architecture in tre livelli:

```text
presentation  →  schermate, bloc e widget condivisi
domain        →  entità e contratti dei repository
data          →  datasource remoti/locali, DTO e repository
```

- Gestione dello stato con `flutter_bloc`.
- Persistenza con `drift`/SQLite e segreti con `flutter_secure_storage`.
- Repository indipendente dalla sorgente: Xtream e M3U implementano `IptvRepository`.
- Analisi pesante di playlist e XMLTV in isolate.

## Struttura

```text
lib/
├── app.dart                 # MaterialApp.router, i18n e temi
├── main.dart                # Inizializzazione dell'app
├── core/                    # Utility, tema, riproduzione e promemoria
├── data/                    # Datasource, DTO e repository
├── domain/                  # Entità e contratti
├── l10n/                    # Traduzioni ARB
└── presentation/            # Schermate, bloc e widget
```

## Per iniziare

### Requisiti

- Flutter 3.x stable con Dart 3.x.
- **Windows:** Visual Studio 2022 con *Desktop development with C++*.
- **Android/TV:** Android SDK; `minSdk 23`, `compileSdk 37`.
- Linux/macOS è previsto dopo la v1.0.0.

### Compilazione

```bash
# Windows
flutter build windows

# Android mobile
flutter build apk --release

# Android TV / Fire TV
flutter build apk --release --target-platform android-arm64
```

Su Windows è disponibile anche lo script di installazione TV:

```powershell
.\scripts\build-install-tv-release.bat 192.168.0.42
```

### Esecuzione

```bash
flutter run -d windows
flutter run -d <id-dispositivo-android>
```

## Configurazione

1. **Xtream Codes:** URL del server, utente e password.
2. **M3U/M3U8:** URL o file locale e, facoltativamente, XMLTV.

Gli account sono cifrati e isolati per impronta account (preferiti, cronologia, categorie e cache). L'import dal telefono usa un server HTTP locale temporaneo e un token di sessione; funziona solo sulla stessa Wi-Fi. Il QR non contiene mai le credenziali.

Per account scaduti o provider non disponibili:

1. Aprire **Gestisci account** dal login.
2. Modificare le credenziali o aggiungere un account.
3. Salvare senza validazione e riprovare quando il provider risponde.

## Internazionalizzazione

L'app e la documentazione sono disponibili in:

| Lingua | README |
| :--- | :--- |
| Español | [README.md](README.md) |
| English | [README.en.md](README.en.md) |
| Français | [README.fr.md](README.fr.md) |
| Deutsch | [README.de.md](README.de.md) |
| Italiano | [README.it.md](README.it.md) |
| Português | [README.pt.md](README.pt.md) |

La lingua dell'app può essere impostata nelle Impostazioni o lasciata automatica in base al sistema.

## Roadmap

- [x] **M0–M8:** base, Xtream, catalogo, player, VOD/serie, EPG, preferiti, M3U e Android TV.
- [x] **M9:** impostazioni, temi, UI multilingua, multi-account, import web, catch-up, ricerca globale e v1.0.0 funzionale.
- [x] **Post-M9:** categorie per account, EPG multi-canale, radio dedicata, login remoto via QR, gestione account senza sessione, PIN opzionale e cache VOD/serie in background.
- [ ] **Firma di release reale** e rimozione definitiva delle credenziali di sviluppo dalla cronologia pubblica.
- [ ] **Notifiche EPG di sistema** con l'app chiusa.
- [ ] **Guida multi-canale completa:** più di 30 canali, paginazione e selezione categoria.
- [ ] **M10:** build Linux (.deb/.AppImage) e macOS (.dmg), notarizzazione e CI per sistema.

## Sviluppo

```bash
flutter analyze
flutter test
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
```

I commit seguono [Conventional Commits](https://www.conventionalcommits.org). La CI esegue analisi e test a ogni push.

## Avviso legale

Kylora è solo un client multimediale. Non fornisce, ospita o distribuisce contenuti, playlist o abbonamenti. L'utente è responsabile dell'uso di contenuti a cui ha diritto e del rispetto delle leggi e delle condizioni del proprio provider. Kylora non supporta contenuti protetti da DRM.

## Licenza

Distribuito con [licenza MIT](LICENSE).
