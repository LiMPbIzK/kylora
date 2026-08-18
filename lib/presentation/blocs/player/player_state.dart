import 'package:equatable/equatable.dart';

/// Estados del reproductor (directo, VOD o series).
sealed class PlayerState extends Equatable {
  const PlayerState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Inicializando el reproductor con el contenido solicitado.
final class PlayerLoading extends PlayerState {
  const PlayerLoading();
}

/// Reproduciendo el contenido en [streamUrl].
final class PlayerPlaying extends PlayerState {
  const PlayerPlaying({required this.streamUrl});

  final String streamUrl;

  @override
  List<Object?> get props => <Object?>[streamUrl];
}

/// Error de reproducción. [retriesLeft] son los reintentos restantes.
final class PlayerError extends PlayerState {
  const PlayerError({required this.message, this.retriesLeft = 0});

  final String message;
  final int retriesLeft;

  @override
  List<Object?> get props => <Object?>[message, retriesLeft];
}
