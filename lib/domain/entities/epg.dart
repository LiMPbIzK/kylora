import 'package:equatable/equatable.dart';

/// Entrada de la guía electrónica de programación (EPG) de un canal.
///
/// Representa un programa emitido entre [start] y [end] con su [title] y
/// una [description] opcional.
class EpgEntry extends Equatable {
  const EpgEntry({
    required this.title,
    required this.start,
    required this.end,
    this.description,
  });

  final String title;

  /// Inicio de emisión del programa.
  final DateTime start;

  /// Fin de emisión del programa.
  final DateTime end;

  /// Sinopsis o descripción del programa (opcional).
  final String? description;

  /// Indica si el programa se está emitiendo ahora según [now].
  bool isOnAir(DateTime now) => !now.isBefore(start) && now.isBefore(end);

  @override
  List<Object?> get props => <Object?>[title, start, end, description];
}
