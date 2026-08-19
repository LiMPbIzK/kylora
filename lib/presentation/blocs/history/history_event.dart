import 'package:equatable/equatable.dart';

/// Eventos del bloc de historial.
sealed class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Carga el historial de reproducción.
final class HistoryStarted extends HistoryEvent {
  const HistoryStarted();
}
