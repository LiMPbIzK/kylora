# Kylora

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Plataformas](https://img.shields.io/badge/Plataformas-Android%20%7C%20Android%20TV%20%7C%20Windows-blue)](https://github.com)
[![Linux](https://img.shields.io/badge/Linux-Pr%C3%B3ximamente-lightgrey?logo=linux&logoColor=white)](https://github.com)
[![macOS](https://img.shields.io/badge/macOS-Pr%C3%B3ximamente-lightgrey?logo=apple&logoColor=white)](https://github.com)
[![Motor](https://img.shields.io/badge/Motor%20de%20v%C3%ADdeo-media__kit%20(libmpv)-E040FB)](https://github.com/media-kit/media-kit)
[![CI](https://img.shields.io/badge/CI-GitHub%20Actions-brightgreen)](https://github.com)
[![Licencia](https://img.shields.io/badge/Licencia-MIT-green.svg)](LICENSE)

> 🌐 **Español** · [English](README.en.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português](README.pt.md)

**Kylora** es un cliente IPTV local-first para Android móvil, Android TV/Google TV, Fire TV y Windows. Está diseñado para un zapping rápido, una navegación cómoda con mando y reproducción fluida de HD, FHD y 4K, sin backend propio, telemetría ni servicios en la nube.

## Características

- **Fuentes Xtream Codes y M3U/XMLTV**, con el mismo contrato de repositorio.
- **Android TV como objetivo principal:** foco D-Pad completo, Leanback, menús contextuales, marquesina de títulos y guía navegable con mando.
- **Reproducción 4K/UHD:** `media_kit`/libmpv con `mediacodec_embed` y `hwdec=mediacodec` en Android; audio/subtítulos, cambio de pista y OSD propio.
- **Multicuenta:** cuentas cifradas, selector de cuenta activa, alta manual y alta desde el móvil mediante QR.
- **Acceso remoto desde el teléfono:** el login muestra un QR para entrar con una cuenta guardada o añadir/editar credenciales desde la misma Wi-Fi.
- **Gestión de cuentas sin sesión:** aunque todas las cuentas estén caducadas, se pueden editar, añadir, borrar, limpiar y reintentar desde el gestor pre-login.
- **PIN opcional** para proteger la gestión de cuentas y el acceso remoto.
- **Categorías visibles y ordenadas por cuenta**, con favoritos de grupo por categoría.
- **TV, Películas, Series y Radio separadas**, con búsqueda global y continuar visualización.
- **EPG:** ahora/siguiente, parrilla diaria, guía multi-canal (hasta 30 canales por vista) y recordatorios dentro de la app.
- **Catch-up/timeshift** en canales Xtream compatibles.
- **Caché local VOD/series** por cuenta. Los catálogos grandes se muestran en cuanto responde la API y la caché se completa en segundo plano.
- **100% local:** credenciales en `flutter_secure_storage` y catálogo en SQLite/Drift. No hay servidor propio ni telemetría.
- **Seis idiomas:** español, inglés, francés, alemán, italiano y portugués, con cambio en caliente desde Ajustes.
- **Cuatro temas:** Nocturne, Expressive, Pacotis y Canvas.

## Arquitectura

Clean Architecture en tres capas:

```text
presentation  →  screens, blocs y widgets compartidos
domain        →  entidades y contratos de repositorio
data          →  datasources remotas/locales, DTOs y repositorios
```

- Estado con `flutter_bloc`.
- Persistencia con `drift`/SQLite y secretos con `flutter_secure_storage`.
- Repositorio agnóstico de fuente: Xtream y M3U implementan `IptvRepository`.
- Parseo pesado de listas y XMLTV en isolates.

## Estructura

```text
lib/
├── app.dart                 # MaterialApp.router, i18n y temas
├── main.dart                # Inicialización de la app
├── core/                    # Utilidades, tema, reproducción y recordatorios
├── data/                    # Datasources, DTOs y repositorios
├── domain/                  # Entidades y contratos
├── l10n/                    # Traducciones ARB
└── presentation/            # Pantallas, blocs y widgets
```

## Primeros pasos

### Requisitos

- Flutter 3.x estable con Dart 3.x.
- **Windows:** Visual Studio 2022 con *Desktop development with C++*.
- **Android/TV:** Android SDK; `minSdk 23`, `compileSdk 37`.
- Linux/macOS están planificados para después de la v1.0.0.

### Compilación

```bash
# Windows
flutter build windows

# Android móvil
flutter build apk --release

# Android TV / Fire TV
flutter build apk --release --target-platform android-arm64
```

En Windows también está el script de instalación para TV:

```powershell
.\scripts\build-install-tv-release.bat 192.168.0.42
```

### Ejecución

```bash
flutter run -d windows
flutter run -d <id-del-dispositivo-android>
```

## Configuración

1. **Xtream Codes:** URL del servidor, usuario y contraseña.
2. **M3U/M3U8:** URL o archivo local y, opcionalmente, XMLTV.

Las cuentas se almacenan cifradas y se aíslan por huella de cuenta (favoritos, historial, categorías y caché). La importación desde el móvil usa un servidor HTTP local temporal y un token de sesión; solo funciona en la misma red Wi-Fi. El QR no contiene credenciales.

Para cuentas caducadas o proveedores no disponibles:

1. Abrir **Gestionar cuentas** desde el login.
2. Editar las credenciales o añadir una cuenta nueva.
3. Guardar sin validar y reintentar el acceso cuando el proveedor responda.

## Internacionalización

La interfaz y la documentación están disponibles en:

| Idioma | README |
| :--- | :--- |
| Español | [README.md](README.md) |
| English | [README.en.md](README.en.md) |
| Français | [README.fr.md](README.fr.md) |
| Deutsch | [README.de.md](README.de.md) |
| Italiano | [README.it.md](README.it.md) |
| Português | [README.pt.md](README.pt.md) |

El idioma de la app se puede fijar en Ajustes o dejar en automático según el sistema.

## Hoja de ruta

- [x] **M0–M8:** fundación, Xtream, catálogo, reproductor, VOD/series, EPG, favoritos, M3U y Android TV.
- [x] **M9:** ajustes, temas, multiidioma, multicuenta, importación web, catch-up, búsqueda global y release v1.0.0 funcional.
- [x] **Post-M9:** categorías por cuenta, EPG multi-canal, radio dedicada, acceso remoto por QR, gestión de cuentas sin sesión, PIN opcional y caché VOD/series en segundo plano.
- [ ] **Firma de release real** y eliminación definitiva de credenciales de desarrollo del historial público.
- [ ] **Notificaciones EPG del sistema** con la app cerrada.
- [ ] **Guía multi-canal completa:** más de 30 canales, paginación y selección de categoría.
- [ ] **M10:** builds de Linux (.deb/.AppImage) y macOS (.dmg), notarización y CI por sistema.

## Desarrollo

```bash
flutter analyze
flutter test
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
```

Commits con [Conventional Commits](https://www.conventionalcommits.org). La CI ejecuta análisis y tests en cada push.

## Aviso legal

Kylora es únicamente un cliente multimedia. No proporciona, aloja ni distribuye contenido, listas ni suscripciones. El usuario es responsable de usar contenido al que tenga derecho y de cumplir las leyes y condiciones de su proveedor. Kylora no admite contenido protegido por DRM.

## Licencia

Distribuido bajo la [Licencia MIT](LICENSE).
