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
  String get language => 'Idioma';
}
