# 🏛️ Arquitectura del Proyecto: Kylora

## 1. Reglas Generales y Filosofía

* **Objetivo:** Cliente IPTV ligero, reactivo y 100% local (sin backend intermedio, hosting ni dominio propio) para Android móvil, Android TV/Fire TV y Windows desktop, desarrollado con Flutter. Soporte para API Xtream Codes, listas M3U/XMLTV y multidioma (i18n).
* **Principios de Diseño:** Local-first (datos y credenciales solo en el dispositivo), Clean Architecture, separación estricta de capas, repositorio agnóstico de fuente, sin telemetría ni análisis.

## 2. Stack Tecnológico y Dependencias Core

* **Lenguaje / Framework:** Dart 3.x / Flutter 3.x (Canal Estable). Compilación nativa Android (ARM64/x86_64) y Windows (C++/x64).
* **Motor de Reproducción:** `media_kit` (basado en `libmpv`). Soporte nativo TS/HLS/MKV, aceleración por hardware, cambio de pistas de audio/subtítulos.
* **Gestión de Estado:** `flutter_bloc` / `Bloc` + `equatable`. Separación estricta de lógica de negocio, trazabilidad de eventos.
* **Cliente HTTP:** `dio`. Timeouts, reintentos, interceptores (User-Agent personalizado), streams para ficheros pesados (M3U/XMLTV).
* **Persistencia Local:** `drift` (SQLite) + `flutter_secure_storage`. Consultas SQL para miles de canales e índices de búsqueda; credenciales cifradas.
* **Navegación / Rutas:** `go_router`.
* **Internacionalización:** `flutter_localizations` + `intl` con ARB generados, detección automática del sistema y cambio manual.

## 3. Estructura de Directorios

```
lib/
├── main.dart                      # Inicialización global (MediaKit, DB, BlocObserver)
├── app.dart                       # MaterialApp.router, configuración i18n y temas
├── l10n/                          # Diccionarios de traducción ARB
├── core/                          # Utilidades globales y transversales
│   ├── constants/                 # Endpoints Xtream, timeouts, user-agents
│   ├── network/                   # Configuración centralizada de Dio
│   ├── theme/                     # Colores, estilos de foco visual para TV
│   └── utils/                     # Parser M3U en isolate, formateador de fechas EPG
├── data/                          # Implementación de datos (Capa Externa)
│   ├── datasources/
│   │   ├── local/                 # Esquema Drift (Channels, Favorites, History), secure storage
│   │   └── remote/                # Cliente API Xtream, descargador M3U/XMLTV
│   ├── models/                    # DTOs (auth, categoría, stream, EPG)
│   └── repositories/              # Implementaciones Xtream y M3U
├── domain/                        # Lógica de Negocio Pura (Capa Interna)
│   ├── entities/                  # UserAccount, Category, StreamItem, EpgEntry
│   └── repositories/              # Contrato abstracto IptvRepository
└── presentation/                  # Capa de Interfaz y Estado
    ├── blocs/                     # auth · live · vod · settings · player
    ├── shared_widgets/            # Widgets reutilizables (focus, errores, loaders)
    └── screens/                   # login, dashboard, live, vod, settings, player
```

## 4. Convenciones de Código y Restricciones Técnicas

* **Identidad:** El proyecto se llama **kylora** (nada de `iptv_player`). Package Android `com.kylora.app`, label "Kylora", binario Windows `kylora.exe`.
* **Contrato de datos:** El repositorio es agnóstico de fuente; tanto Xtream como M3U implementan `IptvRepository`.
* **Persistencia:** SQLite solo a través de drift (nunca SQL crudo fuera de la capa data). Credenciales únicamente en `flutter_secure_storage`.
* **Parseo pesado:** Todo análisis intensivo de listas (M3U/XMLTV) se ejecuta en background isolates para no bloquear la UI.
* **Plataformas:** Android minSdk 23 / compileSdk 37 (exigido por `flutter_secure_storage` v11) / targetSdk 36. Windows requiere Visual Studio 2022 con "Desktop development with C++". Tráfico HTTP en claro acotado mediante `network_security_config.xml` (no flag global).
* **Multiplataforma:** Linux/macOS NO están en alcance de v1.0.0; se añadirán post-v1.0.0 (M10) sin cambios de lógica.
* **Calidad:** `flutter analyze` y `flutter test` deben pasar antes de cerrar cualquier hito. Commits con Conventional Commits.
* **Idiomas:** v1 arranca con es/en; fr/de/it/pt se incorporan en M9.
