import 'package:media_kit/media_kit.dart';

/// Player de media_kit compartido que vive toda la sesión.
///
/// En lugar de crear y destruir un [Player] (y su superficie gráfica
/// OpenGL/ANGLE) en cada navegación dentro y fuera del reproductor — lo que
/// provoca el crash `Lost connection to device` en Windows — se reutiliza un
/// único player. Las pantallas solo cambian de contenido con [Player.open].
class AppPlayer {
  AppPlayer._();

  /// Instancia global única. Requiere que [ensureInitialized] se haya llamado.
  static final AppPlayer instance = AppPlayer._();

  late final Player player = Player();
}
