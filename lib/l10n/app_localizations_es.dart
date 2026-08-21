// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Kylora';

  @override
  String get loginTitle => 'Conectar a IPTV';

  @override
  String get serverUrl => 'URL del Servidor';

  @override
  String get username => 'Usuario';

  @override
  String get password => 'Contraseña';

  @override
  String get loginButton => 'Iniciar Sesión';

  @override
  String get loginErrorInvalidCredentials => 'URL o credenciales no válidas';

  @override
  String get loginErrorNetwork =>
      'No se pudo conectar con el servidor. Revisa la URL y tu conexión.';

  @override
  String get loginErrorUnknown => 'Error inesperado. Inténtalo de nuevo.';

  @override
  String get loginSourceXtream => 'Xtream';

  @override
  String get loginSourceM3u => 'M3U/XMLTV';

  @override
  String get m3uDisplayName => 'Nombre (opcional)';

  @override
  String get m3uPlaylistUrl => 'URL de la lista M3U';

  @override
  String get m3uXmltvUrl => 'URL del EPG XMLTV (opcional)';

  @override
  String get loginErrorM3uParse =>
      'No se pudo leer la lista M3U. Revisa la URL.';

  @override
  String get validationRequired => 'Este campo es obligatorio';

  @override
  String get validationInvalidUrl =>
      'Introduce una URL válida (ej. http://servidor:8080)';

  @override
  String get signOut => 'Cerrar Sesión';

  @override
  String get changeAccount => 'Cambiar cuenta';

  @override
  String get accountStatus => 'Estado de la cuenta';

  @override
  String get accountActive => 'Activa';

  @override
  String get accountExpired => 'Caducada';

  @override
  String accountExpiresOn(String date) {
    return 'Caduca el $date';
  }

  @override
  String accountConnections(String active, String max) {
    return 'Conexiones: $active/$max';
  }

  @override
  String get liveTv => 'Televisión en Directo';

  @override
  String get allCategories => 'Todas';

  @override
  String get noChannels => 'No hay canales en esta categoría';

  @override
  String get liveLoadError =>
      'No se pudo cargar el catálogo en directo. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get retry => 'Reintentar';

  @override
  String get movies => 'Películas';

  @override
  String get series => 'Series';

  @override
  String get favorites => 'Favoritos';

  @override
  String get settings => 'Ajustes';

  @override
  String get epgNoProgram => 'Sin información de programación';

  @override
  String get epgLoadError => 'No se pudo cargar la guía de programación';

  @override
  String get epgGuide => 'Guía de programación';

  @override
  String get nowEpg => 'Ahora';

  @override
  String get nextEpg => 'Siguiente';

  @override
  String get searchPlaceholder => 'Buscar canales, películas...';

  @override
  String get audioTrack => 'Pista de Audio';

  @override
  String get subtitles => 'Subtítulos';

  @override
  String get streamError => 'Error de reproducción. Reintentando...';

  @override
  String get nowPlaying => 'Reproduciendo';

  @override
  String get play => 'Reproducir';

  @override
  String get pause => 'Pausar';

  @override
  String get vodLoadError =>
      'No se pudo cargar el catálogo de películas. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get noMovies => 'No hay películas en esta categoría';

  @override
  String get searchNoResults => 'No se encontraron resultados para tu búsqueda';

  @override
  String get rating => 'Puntuación';

  @override
  String get seriesLoadError =>
      'No se pudo cargar el catálogo de series. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get noSeries => 'No hay series en esta categoría';

  @override
  String get seriesDetailLoadError =>
      'No se pudo cargar los episodios de la serie. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get season => 'Temporada';

  @override
  String get language => 'Idioma';

  @override
  String get history => 'Historial';

  @override
  String get noFavorites => 'No tienes favoritos aún';

  @override
  String get favoritesLoadError => 'No se pudo cargar los favoritos';

  @override
  String get noHistory => 'No hay historial de reproducción';

  @override
  String get historyLoadError => 'No se pudo cargar el historial';

  @override
  String get justNow => 'Ahora mismo';

  @override
  String minutesAgo(int minutes) {
    return 'Hace $minutes min';
  }

  @override
  String hoursAgo(int hours) {
    return 'Hace $hours h';
  }

  @override
  String daysAgo(int days) {
    return 'Hace $days días';
  }
}
