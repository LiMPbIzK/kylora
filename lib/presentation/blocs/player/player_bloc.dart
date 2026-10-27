import 'dart:async';

import 'package:flutter/widgets.dart' show WidgetsBinding;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart' hide PlayerState;

import '../../../core/constants/app_constants.dart';
import 'player_event.dart';
import 'player_state.dart';

/// Bloc del reproductor.
///
/// Reproduce contenido (directo, VOD o series) con un [Player] de media_kit
/// **compartido** que no se destruye al ocultar la pantalla. Este bloc se crea
/// una sola vez (overlay persistente) y recibe cada contenido a través del
/// evento [PlayerPlayRequested], que indica cómo construir su URL.
class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc(this._player) : super(const PlayerLoading()) {
    on<PlayerPlayRequested>(_onPlayRequested);
    on<PlayerRetryRequested>(_onRetryRequested);
    on<PlayerTogglePlayRequested>(_onTogglePlay);
    on<PlayerStreamError>(_onStreamError);

    _errorSubscription = _player.stream.error.listen(
      (String message) => add(PlayerStreamError(message)),
    );
  }

  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 4);

  final Player _player;
  late final StreamSubscription<String> _errorSubscription;

  int _retriesLeft = 0;
  String? _streamUrl;
  Duration? _startPosition;
  Timer? _retryTimer;
  Future<void>? _pendingOpen;
  Future<String> Function() _urlBuilder = _noContent;

  /// El reproductor (compartido) con la capa de presentación.
  Player get player => _player;

  /// La URL del stream actual, si existe.
  String? get streamUrl => _streamUrl;

  /// Resetea el contenido activo (URL y reintentos) sin destruir el player.
  ///
  /// Se llama al cerrar la pantalla para que una nueva reproducción del mismo
  /// contenido vuelva a abrir el stream (evita la pantalla negra si solo se
  /// compara el título).
  void resetContent() {
    _retryTimer?.cancel();
    _retriesLeft = 0;
    _streamUrl = null;
    _startPosition = null;
    _pendingOpen = null;
  }

  static Future<String> _noContent() =>
      throw StateError('No hay contenido en el reproductor');

  Future<void> _onPlayRequested(
    PlayerPlayRequested event,
    Emitter<PlayerState> emit,
  ) async {
    _retryTimer?.cancel();
    _urlBuilder = event.urlBuilder;
    _startPosition = event.startPosition;
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
    try {
      final String url = await _urlBuilder();
      _streamUrl = url;
      // Reenvía el User-Agent de la app al reproducir: algunos CDNs de listas
      // M3U (p. ej. muchas señales de tdtchannels) exigen un UA al pedir el
      // manifest HLS. Mandarlo siempre es inofensivo para los que no lo piden
      // y desbloquea los que sí lo requieren.
      final Media media = Media(
        url,
        httpHeaders: <String, String>{
          'User-Agent': AppConstants.userAgent,
        },
        start: _startPosition,
      );
      _pendingOpen = _player.open(media);
      await _pendingOpen;
      // Refuerza el inicio en la posición guardada. `Media.start` no siempre
      // surte efecto y un `seek` inmediato tras `open` se descarta porque el
      // demuxer aún no conoce la duración; se espera hasta tenerla (máx. ~2 s)
      // antes de buscar.
      final Duration? start = _startPosition;
      if (start != null && start > Duration.zero) {
        await _seekAfterOpen(start);
      }
      // En masters HLS con varias variantes, libmpv puede quedarse sin
      // seleccionar una pista de vídeo (pantalla negra). Se fuerza la primera
      // pista de vídeo disponible un instante después de abrir.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _forceVideoTrack();
      });
      // Los subtítulos se desactivan por defecto; el usuario los activa
      // manualmente desde el menú de pistas.
      await _player.setSubtitleTrack(SubtitleTrack.no());
      emit(PlayerPlaying(streamUrl: url));
    } catch (_) {
      emit(const PlayerError(message: 'streamError'));
    }
  }

  /// Espera a que el demuxer conozca el contenido y busca en [target].
  ///
  /// `Media.start` no se aplica de forma fiable al reabrir un contenido y un
  /// `seek` inmediato tras `open` se descarta si el demuxer aún no tiene
  /// duración. Se espera hasta que `duration > 0` o la posición avance, y se
  /// reintenta el seek para cubrir arranques lentos.
  Future<void> _seekAfterOpen(Duration target) async {
    const int readyAttempts = 20; // ~5 s
    for (int i = 0; i < readyAttempts; i++) {
      if (_player.state.duration > Duration.zero ||
          _player.state.position > Duration.zero) {
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        await _player.seek(target);
        await Future<void>.delayed(const Duration(milliseconds: 400));
        // Si la posición no se acerca al objetivo, reintenta.
        if (_player.state.position >= target ||
            _player.state.position > Duration.zero) {
          break;
        }
      } catch (_) {
        // Si el seek falla, se reintenta; si persiste, se continúa desde
        // el inicio (no crítico).
        await Future<void>.delayed(const Duration(milliseconds: 300));
      }
    }
  }

  /// Fuerza la pista de vídeo activa si libmpv no ha elegido ninguna.
  ///
  /// Algunos HLS en vivo (RTVE, TV3, señales locales con audio en grupos
  /// `#EXT-X-MEDIA` alternos) dejan `videoParams` sin resolver al abrir y
  /// muestran pantalla negra. Seleccionar explícitamente la primera pista de
  /// vídeo disponible obliga al demuxer a resolver sus parámetros.
  void _forceVideoTrack() {
    final List<VideoTrack> videos = _player.state.tracks.video;
    final VideoTrack active = _player.state.track.video;
    final bool hasActive = active.id != VideoTrack.no().id;
    if (!hasActive && videos.isNotEmpty) {
      _player.setVideoTrack(videos.first);
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
    // No se llama a `_player.dispose()`: el player es compartido por toda la
    // sesión (AppPlayer) y debe seguir vivo para la siguiente reproducción.
    return super.close();
  }
}
