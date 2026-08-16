# Kylora 📺

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Plataforma](https://img.shields.io/badge/Plataforma-Android%20%7C%20Android%20TV%20%7C%20Windows-blue)](https://github.com)
[![Linux](https://img.shields.io/badge/Linux-Pr%C3%B3ximamente-lightgrey?logo=linux&logoColor=white)](https://github.com)
[![macOS](https://img.shields.io/badge/macOS-Pr%C3%B3ximamente-lightgrey?logo=apple&logoColor=white)](https://github.com)
[![Motor](https://img.shields.io/badge/Motor%20de%20v%C3%ADdeo-media__kit%20(libmpv)-E040FB)](https://github.com/media-kit/media-kit)
[![CI](https://img.shields.io/badge/CI-GitHub%20Actions-brightgreen)](https://github.com)
[![Licencia](https://img.shields.io/badge/Licencia-MIT-green.svg)](LICENSE)

**Kylora** es un cliente IPTV limpio, local-first y de alto rendimiento diseñado para una reproducción fluida en dispositivos móviles, sticks Android TV/Fire TV y escritorio Windows. Se centra en un bajo consumo de memoria, zapping instantáneo de canales y una experiencia nativa tipo leanback — sin servidores intermedios, sin telemetría, sin análisis de uso.

> 🌐 **English:** [README.en.md](README.en.md)

---

## ✨ Características principales

* **Soporte multi-fuente:** Compatibilidad directa con la API Xtream Codes y listas estáticas M3U/M3U8 con EPG XMLTV.
* **100% local y privado:** Sin backend propio, telemetría ni bases de datos externas. Tus credenciales y listas permanecen estrictamente en tu dispositivo.
* **UI nativa multiplataforma:** Interfaz adaptada con controles táctiles responsivos para móvil/tablet y gestión completa del foco D-Pad para mandos de TV y navegación con teclado.
* **Motor acelerado por hardware:** Impulsado por `media_kit` (libmpv) para demuxing nativo de flujos MPEG-TS, HLS y MKV, con múltiples pistas de audio y selección de subtítulos embebidos.
* **Indexación local inteligente:** El análisis pesado de listas se ejecuta en isolates en segundo plano y se indexa con Drift (SQLite) para búsqueda y categorización instantáneas.
* **Multidioma (i18n):** Soporte nativo de inglés, español, francés, alemán, italiano y portugués.

---

## 🏗️ Arquitectura

Clean Architecture con una separación estricta de responsabilidades en tres capas:

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

* **Gestión de estado:** `flutter_bloc` para una lógica de negocio predecible y trazable.
* **Pureza del dominio:** las reglas de negocio viven en la capa interna sin dependencias del framework.
* **Repositorio agnóstico de fuente:** tanto la implementación Xtream como la M3U cumplen el mismo contrato `IptvRepository`.

## 📁 Estructura del proyecto

```
lib/
├── main.dart                      # Inicialización global (MediaKit, DB, BlocObserver)
├── app.dart                       # MaterialApp.router, i18n y temas
├── l10n/                          # Diccionarios de traducción ARB
├── core/                          # Utilidades transversales
│   ├── constants/                 # Endpoints Xtream, timeouts, user-agents
│   ├── network/                   # Cliente Dio centralizado
│   ├── theme/                     # Colores, estilos de foco para TV
│   └── utils/                     # Parser M3U en isolate, formateador de fechas EPG
├── data/                          # Capa externa
│   ├── datasources/
│   │   ├── local/                 # Esquema Drift (Canales, Favoritos, Historial), almacén seguro
│   │   └── remote/                # Cliente API Xtream, descargador M3U/XMLTV
│   ├── models/                    # DTOs (auth, categoría, stream, EPG)
│   └── repositories/              # Implementaciones Xtream y M3U
├── domain/                        # Lógica de negocio pura
│   ├── entities/                  # UserAccount, Category, StreamItem, EpgEntry
│   └── repositories/              # Contrato IptvRepository
└── presentation/                  # Capa de interfaz
    ├── blocs/                     # auth · live · vod · settings · player
    ├── shared_widgets/            # items enfocables, vistas de error, loaders
    └── screens/                   # login, dashboard, live, vod, settings, player
```

---

## 🚀 Primeros pasos

### Requisitos previos

* [Flutter 3.x](https://docs.flutter.dev/get-started/install) (canal estable) con Dart 3.x
* **Windows:** Visual Studio 2022 con la carga de trabajo *Desktop development with C++* (toolchain CMake)
* **Android / Android TV:** Android SDK (minSdk 23, targetSdk 35)

> **Linux y macOS** se añadirán tras la v1.0.0 (hito M10): el código base es multiplataforma, solo requieren builds y packaging específicos.

### Compilación

```bash
# Escritorio Windows
flutter build windows

# APK Android (móvil)
flutter build apk --release

# APK Android TV / Fire TV (leanback)
flutter build apk --release --target-platform android-arm64
```

### Ejecución

```bash
flutter run -d windows
flutter run -d <id-del-dispositivo-android>
```

---

## ⚙️ Configuración

Kylora admite dos fuentes de suscripción:

1. **API Xtream Codes** — introduce la URL del servidor de tu proveedor, nombre de usuario y contraseña.
2. **Lista M3U/M3U8** — carga un archivo local o una URL remota, opcionalmente junto a una fuente de EPG XMLTV.

Las credenciales se almacenan cifradas mediante `flutter_secure_storage`; las listas se indexan localmente en SQLite. Nada sale de tu dispositivo salvo las peticiones directas a tu proveedor.

> ⚠️ **Tráfico en claro:** Se admiten flujos HTTP (sin SSL) para proveedores sin HTTPS. Esto se delimita mediante una configuración de seguridad de red.

---

## 🌍 Internacionalización

Construida sobre `flutter_localizations` + `intl` con archivos ARB generados y detección automática del idioma del sistema.

| Locale | Estado |
| :--- | :--- |
| Español | ✅ |
| Inglés | ✅ |
| Francés | 🔜 Hoja de ruta |
| Alemán | 🔜 Hoja de ruta |
| Italiano | 🔜 Hoja de ruta |
| Portugués | 🔜 Hoja de ruta |

---

## 🗺️ Hoja de ruta

- [ ] **M0 — Fundación:** andamiaje del proyecto, dependencias, estructura de carpetas, i18n (es/en), tema, router
- [ ] **M1 — Suscripción Xtream:** login, almacenamiento seguro, persistencia de sesión, estado de la cuenta
- [ ] **M2 — Catálogo en directo:** esquema Drift + indexado, categorías, lista de canales con logos
- [ ] **M3 — Reproductor:** integración de media_kit, OSD de controles, pistas de audio/subtítulos, reintentos
- [ ] **M4 — VOD y Series:** rejillas, vistas de detalle, episodios de series
- [ ] **M5 — EPG:** ahora/siguiente en la lista de canales, vista de programación completa, XMLTV + short EPG de Xtream
- [ ] **M6 — Favoritos, historial y búsqueda:** favoritos persistentes, historial de reproducción, búsqueda instantánea
- [ ] **M7 — Fuente M3U/XMLTV:** selector de fuente, parseo en isolate en segundo plano, contrato unificado
- [ ] **M8 — Android TV / Fire TV:** gestión de foco D-Pad, banner leanback, navegación con mando
- [ ] **M9 — Ajustes y release:** selector de idioma, gestión de caché, idiomas restantes, v1.0.0
- [ ] **M10 — Portabilidad Linux/macOS (post-v1.0.0):** builds de escritorio para Linux (.deb/.AppImage) y macOS (.dmg), notarización y CI por SO — sin cambios de lógica (v1.1)

---

## 🛠️ Desarrollo

* **Commits:** [Conventional Commits](https://www.conventionalcommits.org) (`feat:`, `fix:`, `docs:`, `chore:`).
* **Lint y análisis:** `flutter analyze`
* **Tests:** `flutter test`
* **Generación de código** (Drift/l10n): `dart run build_runner build --delete-conflicting-outputs`
* **CI:** GitHub Actions ejecuta `flutter analyze` y `flutter test` en cada push.

---

## ⚠️ Aviso legal

Kylora es únicamente un **cliente** reproductor multimedia. **No** proporciona, aloja ni distribuye contenido, flujos, listas ni suscripciones.

* Eres responsable de cualquier suscripción IPTV o lista que utilices, así como de cumplir las condiciones de servicio de tu proveedor y las leyes de derechos de autor aplicables en tu jurisdicción.
* Kylora **no** admite contenido protegido por DRM.
* La retransmisión de contenido no autorizado puede ser ilegal en tu país. Usa Kylora únicamente con contenido que poseas o cuyo acceso tengas derecho.

---

## 📄 Licencia

Distribuido bajo la [Licencia MIT](LICENSE). Consulta `LICENSE` para más información.
