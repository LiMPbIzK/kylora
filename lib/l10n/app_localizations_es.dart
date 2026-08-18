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
  String get liveTv => 'Televisión en Directo';

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
