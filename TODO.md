# 📋 Contenido. Lista de Tareas y Progreso: Kylora

## Hito 0: Fundación

- [x] Entorno: Flutter SDK portable en J:\Flutter, PATH y variables configuradas
- [x] Android SDK localizado (J:\AndroidSDK), licencias aceptadas, cmdline-tools normalizados
- [x] `flutter create` (nombre kylora, org com.kylora, plataformas android + windows)
- [x] `pubspec.yaml` con dependencias core (media_kit, dio, flutter_bloc, drift, secure_storage, go_router, intl)
- [x] Configuración l10n (`l10n.yaml`, ARB en/es) y `generate: true`
- [x] Estructura de carpetas `lib/` (core, data, domain, presentation)
- [x] `main.dart`, `app.dart`, tema y `go_router` con dashboard vacío
- [x] Configuración Android (appId com.kylora.app, minSdk 23, label Kylora, network_security_config, leanback)
- [x] Configuración Windows (título ventana, binario kylora.exe)
- [x] CI workflow GitHub Actions (analyze + test)
- [x] `flutter analyze` y `flutter test` en verde
- [x] Compilar APK Android (verificación de hito)
- [x] Compilar Windows (kylora.exe + libmpv) — resuelto con NTFS en J:, Modo desarrollador activado y componente ATL añadido a Build Tools
- [x] Sección del tutorial M0 → `J:\Codigo\tutoriales\proyecto-kylora\fundacion-del-proyecto.md`

## Hito 1: Suscripción Xtream

- [ ] Login (URL/usuario/contraseña), `dio_client`, auth `player_api.php`
- [ ] Credenciales en secure_storage, AuthBloc con auto-login
- [ ] Estado de cuenta (expiración, conexiones)

## Hito 2: Catálogo en directo

- [ ] Esquema Drift + indexado, categorías, lista de canales con logos

## Hito 3: Reproductor

- [ ] Integración media_kit, OSD de controles, pistas audio/subtítulos, reintentos

## Hito 4: VOD y Series

- [ ] Rejillas, vistas de detalle, episodios de series

## Hito 5: EPG

- [ ] Ahora/siguiente en lista, vista de programación completa, XMLTV + short EPG

## Hito 6: Favoritos, historial y búsqueda

- [ ] Favoritos persistentes, historial de reproducción, búsqueda instantánea

## Hito 7: Fuente M3U/XMLTV

- [ ] Selector de fuente, parseo en isolate, contrato unificado

## Hito 8: Android TV / Fire TV

- [ ] Gestión de foco D-Pad, banner leanback, navegación con mando

## Hito 9: Ajustes y release

- [ ] Selector de idioma, gestión de caché, idiomas fr/de/it/pt, v1.0.0

## Hito 10: Portabilidad Linux/macOS (post-v1.0.0)

- [ ] Builds Linux (.deb/.AppImage) y macOS (.dmg), notarización, CI por SO — v1.1
