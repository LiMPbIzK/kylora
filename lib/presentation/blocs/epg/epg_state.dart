import 'package:equatable/equatable.dart';

import '../../../domain/entities/epg.dart';

/// Estados de la guía electrónica de programación (EPG).
sealed class EpgState extends Equatable {
  const EpgState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial: sin ninguna carga EPG en curso.
final class EpgIdle extends EpgState {
  const EpgIdle();

  @override
  List<Object?> get props => <Object?>[];
}

/// Cargando el EPG de un canal.
final class EpgLoading extends EpgState {
  const EpgLoading(this.streamId);

  final int streamId;

  @override
  List<Object?> get props => <Object?>[streamId];
}

/// EPG corto (ahora/siguiente) cargado para un canal.
final class EpgNowNextLoaded extends EpgState {
  const EpgNowNextLoaded({
    required this.streamId,
    required this.now,
    required this.next,
    this.loadedAt,
  });

  final int streamId;

  /// Programa en emisión (puede ser nulo si no hay programa actual).
  final EpgEntry? now;

  /// Siguiente programa programado (puede ser nulo).
  final EpgEntry? next;

  /// Marca de tiempo de la carga (para refrescar el "ahora").
  final DateTime? loadedAt;

  @override
  List<Object?> get props => <Object?>[streamId, now, next];
}

/// Programación completa de un canal cargada.
final class EpgGuideLoaded extends EpgState {
  const EpgGuideLoaded({
    required this.streamId,
    required this.channelName,
    required this.entries,
  });

  final int streamId;
  final String channelName;
  final List<EpgEntry> entries;

  @override
  List<Object?> get props => <Object?>[streamId, channelName, entries];
}

/// No hay información EPG para el canal.
final class EpgEmpty extends EpgState {
  const EpgEmpty(this.streamId);

  final int streamId;

  @override
  List<Object?> get props => <Object?>[streamId];
}

/// Error al cargar el EPG de un canal.
final class EpgFailure extends EpgState {
  const EpgFailure(this.streamId);

  final int streamId;

  @override
  List<Object?> get props => <Object?>[streamId];
}
