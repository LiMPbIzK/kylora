import '../../domain/entities/epg.dart';

/// DTO de una entrada de la guía de programación (EPG).
///
/// Unifica el formato devuelto tanto por `get_short_epg` como por
/// `get_simple_data_table` de la API Xtream Codes. En ambos casos los
/// programas llegan en el bloque `epg_listings` como lista de objetos con
/// `title`, `start`, `end` y opcionalmente `description`.
class XtreamEpgDto {
  const XtreamEpgDto({
    required this.title,
    required this.start,
    required this.end,
    this.description,
  });

  final String title;
  final DateTime start;
  final DateTime end;
  final String? description;

  /// Parsea cada listing del bloque `epg_listings` de forma tolerante:
  /// ignora las entradas sin título o con fechas no reconocibles.
  static EpgEntry? parseListing(Map<String, dynamic> json) {
    final String title = json['title']?.toString() ?? '';
    if (title.isEmpty) return null;

    final DateTime? start = _parseTime(json['start']);
    final DateTime? end = _parseTime(json['end']);
    if (start == null || end == null) return null;

    return EpgEntry(
      title: title,
      start: start,
      end: end,
      description: json['description']?.toString(),
    );
  }

  /// Convierte un valor de tiempo a [DateTime].
  ///
  /// Xtream suele devolver epoch (segundos), pero por robustez se aceptan
  /// también milisegundos y cadenas ISO 8601.
  static DateTime? _parseTime(dynamic value) {
    if (value == null) return null;
    final int? epochSeconds = int.tryParse(value.toString());
    if (epochSeconds != null) {
      if (epochSeconds > 100000000000) {
        return DateTime.fromMillisecondsSinceEpoch(epochSeconds);
      }
      return DateTime.fromMillisecondsSinceEpoch(epochSeconds * 1000);
    }
    return DateTime.tryParse(value.toString());
  }
}
