import 'package:equatable/equatable.dart';

/// Eventos de la guía electrónica de programación (EPG).
sealed class EpgEvent extends Equatable {
  const EpgEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Carga el EPG corto (ahora/siguiente) de un canal.
final class EpgNowNextRequested extends EpgEvent {
  const EpgNowNextRequested(this.streamId, {this.limit = 4});

  final int streamId;
  final int limit;

  @override
  List<Object?> get props => <Object?>[streamId, limit];
}

/// Carga la programación EPG completa de un canal.
final class EpgGuideRequested extends EpgEvent {
  const EpgGuideRequested(this.streamId, this.channelName);

  final int streamId;
  final String channelName;

  @override
  List<Object?> get props => <Object?>[streamId, channelName];
}
