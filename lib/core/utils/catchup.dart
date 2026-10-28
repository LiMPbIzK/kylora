import '../../domain/entities/epg.dart';

/// Indica si un programa pasado se puede abrir mediante catch-up.
///
/// Si el proveedor no marca el canal con archivo, o el programa aún no ha
/// terminado, no se ofrece la acción. [archiveDurationDays] limita la ventana
/// si el proveedor la informa.
bool isCatchupAvailable({
  required bool hasArchive,
  int? archiveDurationDays,
  required EpgEntry program,
  DateTime? now,
}) {
  if (!hasArchive) return false;
  final DateTime current = now ?? DateTime.now();
  if (!program.end.isBefore(current)) return false;
  final int? days = archiveDurationDays;
  if (days != null && days > 0) {
    final DateTime oldest = current.subtract(Duration(days: days));
    if (program.start.isBefore(oldest)) return false;
  }
  return true;
}

/// Formatea el inicio con el formato que usa Xtream en `/timeshift`:
/// `YYYY-MM-DD:HH-mm`.
String formatCatchupStart(DateTime start) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${start.year.toString().padLeft(4, '0')}-'
      '${two(start.month)}-${two(start.day)}:'
      '${two(start.hour)}-${two(start.minute)}';
}

/// Construye una URL de timeshift estándar de Xtream.
///
/// El último parámetro es la duración del programa en minutos, no los días de
/// archivo del canal.
String buildXtreamCatchupUrl({
  required String serverUrl,
  required String username,
  required String password,
  required int streamId,
  required EpgEntry program,
}) {
  final String base = serverUrl.replaceFirst(RegExp(r'/+$'), '');
  final int minutes = program.end.difference(program.start).inMinutes;
  final int duration = minutes > 0 ? minutes : 1;
  return '$base/timeshift/'
      '${Uri.encodeComponent(username)}/'
      '${Uri.encodeComponent(password)}/'
      '$duration/${formatCatchupStart(program.start)}/$streamId.ts';
}
