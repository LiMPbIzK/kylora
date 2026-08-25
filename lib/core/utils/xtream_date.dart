/// Utilidades para fechas proporcionadas por las fuentes IPTV.
library;

/// Parsea una fecha de una fuente Xtream/M3U al formato habitual
/// `YYYY-MM-DD HH:MM:SS` (también soporta ISO-8601 y epoch en
/// segundos/milisegundos). Devuelve `null` si no se puede interpretar.
DateTime? parseXtreamDate(String? value) {
  if (value == null || value.isEmpty) return null;

  final String trimmed = value.trim();

  // Epoch (segundos o milisegundos).
  final int? epoch = int.tryParse(trimmed);
  if (epoch != null) {
    if (epoch.abs() > 100000000000) {
      // Milisegundos.
      return DateTime.fromMillisecondsSinceEpoch(epoch);
    }
    return DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
  }

  // `2024-01-15 10:30:00` → reemplaza el espacio por 'T' para ISO-8601.
  final String normalized = trimmed.replaceFirst(' ', 'T');
  return DateTime.tryParse(normalized);
}