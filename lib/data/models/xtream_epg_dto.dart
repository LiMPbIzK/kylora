import 'dart:convert';

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
    final String title = _decodeEpgText(json['title']?.toString() ?? '');
    if (title.isEmpty) return null;

    final DateTime? start = _parseTime(json['start']);
    final DateTime? end = _parseTime(json['end']);
    if (start == null || end == null) return null;

    final String? rawDescription = json['description']?.toString();
    return EpgEntry(
      title: title,
      start: start,
      end: end,
      description: rawDescription == null
          ? null
          : _decodeEpgText(rawDescription),
    );
  }

  /// Algunos proveedores Xtream codifican en base64 el `title` y el
  /// `description` de los listings. Si [raw] parece base64 y descodifica a
  /// texto imprimible se devuelve el texto descodificado; en caso contrario
  /// se devuelve [raw] tal cual.
  static String _decodeEpgText(String raw) {
    final String candidate = raw.trim();
    if (candidate.length < 4 || candidate.length % 4 != 0) return raw;
    if (!RegExp(r'^[A-Za-z0-9+/]+={0,2}$').hasMatch(candidate)) return raw;
    try {
      final List<int> bytes = base64.decode(candidate);
      final String decoded = utf8.decode(bytes, allowMalformed: false);
      if (_isPrintable(decoded)) return decoded;
    } catch (_) {
      // No era base64 válido: se conserva el texto original.
    }
    return raw;
  }

  /// Indica si [text] está compuesto casi por completo de caracteres
  /// imprimibles (excluye controles, salvo salto de línea).
  static bool _isPrintable(String text) {
    if (text.isEmpty) return false;
    int printable = 0;
    for (final int code in text.codeUnits) {
      if (code == 0x09 || code == 0x0A || code == 0x0D) {
        continue;
      }
      if (code < 0x20 || code == 0x7F) return false;
      printable++;
    }
    return printable / text.length > 0.8;
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
