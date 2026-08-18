import 'package:equatable/equatable.dart';

import '../../../domain/entities/channel.dart';

/// Estados del reproductor en directo.
sealed class PlayerState extends Equatable {
  const PlayerState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Inicializando el reproductor con el canal solicitado.
final class PlayerLoading extends PlayerState {
  const PlayerLoading();
}

/// Reproduciendo [channel] en directo.
final class PlayerPlaying extends PlayerState {
  const PlayerPlaying({required this.channel, required this.streamUrl});

  final Channel channel;
  final String streamUrl;

  @override
  List<Object?> get props => <Object?>[channel, streamUrl];
}

/// Error de reproducción. [retriesLeft] son los reintentos restantes.
final class PlayerError extends PlayerState {
  const PlayerError({required this.message, this.retriesLeft = 0});

  final String message;
  final int retriesLeft;

  @override
  List<Object?> get props => <Object?>[message, retriesLeft];
}
