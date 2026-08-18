import 'package:equatable/equatable.dart';

/// Eventos del reproductor (directo, VOD o series).
sealed class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Carga y reproduce el contenido cuya URL construye [urlBuilder].
final class PlayerPlayRequested extends PlayerEvent {
  const PlayerPlayRequested(this.urlBuilder);

  final Future<String> Function() urlBuilder;

  @override
  List<Object?> get props => <Object?>[];
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
