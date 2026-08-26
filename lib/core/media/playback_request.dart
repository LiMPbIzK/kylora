/// Solicitud de reproducción para el overlay de reproducción.
/// Encapsula el título a mostrar y la función que construye la URL del stream.
class PlaybackRequest {
  const PlaybackRequest({
    required this.title,
    required this.urlBuilder,
    this.contentType,
    this.contentId,
    this.openGuide = false,
    this.startPosition,
    this.logo,
  });

  /// Título del contenido que se reproduce.
  final String title;

  /// Construye la URL del stream a reproducir.
  final Future<String> Function() urlBuilder;

  /// Tipo de contenido para historial ('live', 'vod', 'series').
  final String? contentType;

  /// ID del contenido para historial.
  final int? contentId;

  /// Si es true, al iniciar la reproducción se abre la guía embebida del canal
  /// dentro del reproductor (vista de programación overlay, sin detener el stream).
  final bool openGuide;

  /// Posición en la que iniciar la reproducción (para "Continuar visualización").
  final Duration? startPosition;

  /// URL del póster/logo para el historial y la vista de reanudación.
  final String? logo;
}
