/// Solicitud de reproducción para el overlay de reproducción.
/// Encapsula el título a mostrar y la función que construye la URL del stream.
class PlaybackRequest {
  const PlaybackRequest({required this.title, required this.urlBuilder});

  /// Título del contenido que se reproduce.
  final String title;

  /// Construye la URL del stream a reproducir.
  final Future<String> Function() urlBuilder;
}
