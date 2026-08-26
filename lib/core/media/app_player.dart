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

  /// Tamaño de caché del demuxer (libmpv `demuxer-max-bytes`).
  ///
  /// Se sube desde el valor por defecto (32 MB) a 128 MB para que libmpv pueda
  /// inicializar el file-cache al leer manifiestos HLS "multipista" (audio en
  /// grupos `#EXT-X-MEDIA` alternos, p. ej. RTVE/TV3) sin quedarse en píxeles
  /// negros por no obtener los parámetros de codec a tiempo
  /// (`Could not find codec parameters ... unspecified size`).
  static const int demuxerBufferBytes = 128 * 1024 * 1024;

  late final Player player = Player(
    configuration: const PlayerConfiguration(
      bufferSize: demuxerBufferBytes,
      protocolWhitelist: <String>[
        'udp',
        'rtp',
        'tcp',
        'tls',
        'data',
        'file',
        'http',
        'https',
        'crypto',
        'mms',
        'rtsp',
        'rtmpt',
        'rtmpe',
      ],
    ),
  );
}
