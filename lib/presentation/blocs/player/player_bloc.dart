import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart' hide PlayerState;

import '../../../domain/entities/channel.dart';
import '../../../domain/repositories/iptv_repository.dart';
import 'player_event.dart';
import 'player_state.dart';

/// Bloc del reproductor en directo.
///
/// Posee un [Player] de media_kit, gestiona la carga del canal, los
/// reintentos ante errores y el play/pause del stream.
class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc(this._repository) : super(const PlayerLoading()) {
    on<PlayerChannelRequested>(_onChannelRequested);
    on<PlayerRetryRequested>(_onRetryRequested);
    on<PlayerTogglePlayRequested>(_onTogglePlay);
    on<PlayerStreamError>(_onStreamError);

    _player = Player();
    _errorSubscription = _player.stream.error.listen(
      (String message) => add(PlayerStreamError(message)),
    );
  }

  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 4);

  final IptvRepository _repository;

  late final Player _player;
  late final StreamSubscription<String> _errorSubscription;

  int _retriesLeft = 0;
  Channel? _channel;
  String? _streamUrl;
  Timer? _retryTimer;
  Future<void>? _pendingOpen;

  /// El reproductor compartido con la capa de presentación.
  Player get player => _player;

  /// El canal que se está reproduciendo, si existe.
  Channel? get channel => _channel;

  /// La URL del stream actual, si existe.
  String? get streamUrl => _streamUrl;

  Future<void> _onChannelRequested(
    PlayerChannelRequested event,
    Emitter<PlayerState> emit,
  ) async {
    _retryTimer?.cancel();
    _channel = event.channel;
    _retriesLeft = 0;
    emit(const PlayerLoading());
    await _open(emit);
  }

  Future<void> _onRetryRequested(
    PlayerRetryRequested event,
    Emitter<PlayerState> emit,
  ) async {
    emit(const PlayerLoading());
    await _open(emit);
  }

  Future<void> _open(Emitter<PlayerState> emit) async {
    final Channel channel = _channel!;
    try {
      final String url = await _repository.buildStreamUrl(channel);
      _streamUrl = url;
      final Media media = Media(url);
      _pendingOpen = _player.open(media);
      await _pendingOpen;
      emit(PlayerPlaying(channel: channel, streamUrl: url));
    } catch (_) {
      emit(const PlayerError(message: 'streamError'));
    }
  }

  void _onStreamError(PlayerStreamError event, Emitter<PlayerState> emit) {
    if (!isClosed && _retriesLeft < maxRetries) {
      _retriesLeft++;
      emit(PlayerError(message: event.message, retriesLeft: _retriesLeft));
      _retryTimer = Timer(retryDelay, () {
        if (!isClosed) add(const PlayerRetryRequested());
      });
      return;
    }
    if (!isClosed) {
      emit(PlayerError(message: event.message));
    }
  }

  Future<void> _onTogglePlay(
    PlayerTogglePlayRequested event,
    Emitter<PlayerState> emit,
  ) async {
    await _player.playOrPause();
  }

  @override
  Future<void> close() {
    _retryTimer?.cancel();
    _errorSubscription.cancel();
    _player.dispose();
    return super.close();
  }
}
