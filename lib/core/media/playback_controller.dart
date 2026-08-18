import 'package:flutter/foundation.dart';

import 'playback_request.dart';

/// Controla la reproducción como overlay global.
///
/// El reproductor vive de forma persistente en el árbol (nunca se desmonta),
/// evitando los crasheos de media_kit/ANGLE en Windows que ocurrían al crear y
/// destruir el `Video` (VideoOutput) en cada navegación.
class PlaybackController extends ChangeNotifier {
  PlaybackRequest? _current;

  /// Contenido en reproducción, o null si el reproductor está oculto.
  PlaybackRequest? get current => _current;

  bool get isPlaying => _current != null;

  /// Abre la reproducción de [request].
  void play(PlaybackRequest request) {
    _current = request;
    notifyListeners();
  }

  /// Oculta el reproductor (no lo desmonta; sigue vivo para la próxima vez).
  void stop() {
    _current = null;
    notifyListeners();
  }
}
