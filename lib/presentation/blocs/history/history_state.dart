import 'package:equatable/equatable.dart';

import '../../../domain/entities/history_item.dart';

/// Estados del bloc de historial.
sealed class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Cargando historial.
final class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

/// Historial cargado.
final class HistoryLoaded extends HistoryState {
  const HistoryLoaded(this.items);

  final List<HistoryItem> items;

  @override
  List<Object?> get props => <Object?>[items];
}

/// Error al cargar historial.
final class HistoryFailure extends HistoryState {
  const HistoryFailure(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
