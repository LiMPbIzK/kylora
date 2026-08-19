/// Solicitud de reproducción para el overlay de reproducción.
/// Encapsula el título a mostrar y la función que construye la URL del stream.
class PlaybackRequest {
  const PlaybackRequest({
    required this.title,
    required this.urlBuilder,
    this.contentType,
    this.contentId,
  });

  /// Título del contenido que se reproduce.
  final String title;

  /// Construye la URL del stream a reproducir.
  final Future<String> Function() urlBuilder;

  /// Tipo de contenido para historial ('live', 'vod', 'series').
  final String? contentType;

  /// ID del contenido para historial.
  final int? contentId;
}
