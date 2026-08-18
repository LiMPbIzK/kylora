import 'package:equatable/equatable.dart';

import '../../../domain/entities/channel.dart';

/// Eventos del reproductor en directo.
sealed class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Inicia la reproducción de [channel].
final class PlayerChannelRequested extends PlayerEvent {
  const PlayerChannelRequested(this.channel);

  final Channel channel;

  @override
  List<Object?> get props => <Object?>[channel];
}

/// Reintenta la reproducción tras un error.
final class PlayerRetryRequested extends PlayerEvent {
  const PlayerRetryRequested();
}

/// Pausa o reanuda el stream.
final class PlayerTogglePlayRequested extends PlayerEvent {
  const PlayerTogglePlayRequested();
}

/// Error del stream emitido por el player. Evento interno para poder
/// actualizar el estado dentro de un handler.
final class PlayerStreamError extends PlayerEvent {
  const PlayerStreamError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
