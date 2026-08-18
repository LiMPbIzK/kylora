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
  String get validationRequired => 'Este campo es obligatorio';

  @override
  String get validationInvalidUrl =>
      'Introduce una URL válida (ej. http://servidor:8080)';

  @override
  String get signOut => 'Cerrar Sesión';

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
}
