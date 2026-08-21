import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart' hide PlayerState;
import 'package:media_kit_video/media_kit_video.dart';

import '../../../core/media/app_player.dart';
import '../../../core/media/playback_controller.dart';
import '../../../core/media/playback_request.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/content_type.dart';
import '../../../domain/entities/history_item.dart';
import '../../../domain/repositories/iptv_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../blocs/player/player_bloc.dart';
import '../../blocs/player/player_event.dart';
import '../../blocs/player/player_state.dart';

/// Reproductor genérico (directo, VOD o series) con OSD de controles y pistas.
///
/// Se monta **una sola vez** como overlay persistente y es dirigido por
/// [PlaybackController]: nunca se desmonta al navegar, de modo que el `Video`
/// (y su superficie gráfica) no se recrea y se evita el crash de ANGLE/Windows.
class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key, required this.controller});

  final PlaybackController controller;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

/// Tipo de selector de pistas abierto en el OSD (audio o subtítulos).
enum _TrackPickerMode { audio, subtitles }

class _PlayerScreenState extends State<PlayerScreen> {
  late final VideoController _videoController;
  late final PlayerBloc _bloc;
  Timer? _hideTimer;
  bool _osdVisible = true;
  bool _isFullscreen = false;
  String _title = '';
  _TrackPickerMode? _picker;

  @override
  void initState() {
    super.initState();
    // Un único bloc/player para toda la sesión (no se recrea por navegación).
    _bloc = PlayerBloc(AppPlayer.instance.player);
    _videoController = VideoController(_bloc.player);
    widget.controller.addListener(_onControllerChanged);
    _onControllerChanged();
  }

  void _onControllerChanged() {
    final PlaybackRequest? request = widget.controller.current;
    if (request != null) {
      if (_title != request.title || _bloc.streamUrl == null) {
        setState(() => _title = request.title);
        _bloc.add(PlayerPlayRequested(request.urlBuilder));
        _recordHistory(request);
      }
    } else if (!_bloc.isClosed) {
      _bloc.player.stop();
    }
  }

  void _recordHistory(PlaybackRequest request) {
    if (request.contentType == null || request.contentId == null) return;
    final IptvRepository repository = context.read<IptvRepository>();
    repository.addToHistory(
      HistoryItem(
        contentId: request.contentId!,
        contentType: ContentType.values.byName(request.contentType!),
        name: request.title,
        watchedAt: DateTime.now(),
      ),
    );
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _osdVisible) {
        setState(() => _osdVisible = false);
      }
    });
  }

  /// Muestra el OSD y programa su ocultado tras la inactividad.
  void _showOsd() {
    if (!_osdVisible) {
      setState(() => _osdVisible = true);
    }
    _scheduleHide();
  }

  void _onMouseHover(PointerHoverEvent event) => _showOsd();

  void _toggleOsd() {
    setState(() => _osdVisible = !_osdVisible);
    if (_osdVisible) _scheduleHide();
  }

  void _cancelHide() {
    _hideTimer?.cancel();
  }

  void _closePlayer() {
    _bloc.player.stop();
    widget.controller.stop();
  }

  /// Alterna pantalla completa usando el fullscreen nativo de media_kit.
  ///
  /// No se usa `toggleFullscreen(context)` porque empuja una ruta al Navigator
  /// raíz, que quedaría oculta detrás del overlay persistente del reproductor.
  /// En su lugar se invoca el modo nativo directo (`Utils.EnterNativeFullscreen`
  /// en Windows/macOS/Linux; modo inmersivo en Android).
  Future<void> _toggleFullscreen() async {
    setState(() {
      _isFullscreen = !_isFullscreen;
      _scheduleHide();
    });
    if (_isFullscreen) {
      await defaultEnterNativeFullscreen();
    } else {
      await defaultExitNativeFullscreen();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _hideTimer?.cancel();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_bloc.player.state.playing,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) _closePlayer();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: MouseRegion(
          onHover: _onMouseHover,
          onExit: (_) => _scheduleHide(),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleOsd,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Video(
                  controller: _videoController,
                  // Desactiva los controles nativos de media_kit (barra de
                  // progreso y botones superpuestos), que interferían con el
                  // OSD propio y capturan los gestos del menú de ajustes.
                  controls: NoVideoControls,
                ),
                BlocBuilder<PlayerBloc, PlayerState>(
                  bloc: _bloc,
                  builder: (context, state) {
                    if (state is PlayerLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }
                    if (state is PlayerError && state.retriesLeft == 0) {
                      return _ErrorOverlay(
                        message: AppLocalizations.of(context)!.streamError,
                        onRetry: () =>
                            _bloc.add(const PlayerRetryRequested()),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                if (_osdVisible) _buildOsd(),
                if (_picker != null)
                  _buildTrackPicker(AppLocalizations.of(context)!),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOsd() {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return IgnorePointer(
      ignoring: false,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0x99000000), Color(0x00000000)],
          ),
        ),
        child: SafeArea(
child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      IconButton(
                        tooltip: l10n.settings,
                        icon: const Icon(Icons.arrow_back),
                        color: Colors.white,
                        onPressed: _closePlayer,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              l10n.nowPlaying,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: Colors.white70),
                            ),
                            Text(
                              _title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _buildProgressBar(l10n),
                  _buildControlBar(l10n),
                ],
              ),
        ),
      ),
    );
  }

  /// Barra de progreso con búsqueda (seek) para contenido VOD/series.
  ///
  /// Muestra un slider entre el tiempo actual y la duración cuando el stream
  /// tiene duración conocida (no aplica a directos en vivo). Arrastrar o pulsar
  /// en la barra salta a la posición indicada.
  Widget _buildProgressBar(AppLocalizations l10n) {
    return StreamBuilder<Duration>(
      stream: _bloc.player.stream.position,
      initialData: _bloc.player.state.position,
      builder: (context, snapshot) {
        final Duration position = snapshot.data ?? Duration.zero;
        final Duration duration = _bloc.player.state.duration;
        if (duration.inMilliseconds <= 0) {
          return const SizedBox.shrink();
        }
        final double value = position.inMilliseconds
            .clamp(0, duration.inMilliseconds)
            .toDouble();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: <Widget>[
              Text(
                _formatPosition(position),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 12,
                    ),
                  ),
                  child: Slider(
                    value: value,
                    max: duration.inMilliseconds.toDouble(),
                    activeColor: AppColors.primary,
                    inactiveColor: Colors.white24,
                    onChangeStart: (_) => _cancelHide(),
                    onChangeEnd: (_) => _scheduleHide(),
                    onChanged: (double v) {
                      _bloc.player.seek(
                        Duration(milliseconds: v.round()),
                      );
                    },
                  ),
                ),
              ),
              Text(
                _formatPosition(duration),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlBar(AppLocalizations l10n) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: <Color>[Color(0xCC000000), Color(0x00000000)],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: <Widget>[
          const Spacer(),
          IconButton(
            tooltip: l10n.audioTrack,
            icon: const Icon(Icons.music_note, color: Colors.white, size: 28),
            onPressed: () {
              _cancelHide();
              setState(() => _picker = _TrackPickerMode.audio);
            },
          ),
          StreamBuilder<bool>(
            stream: _bloc.player.stream.playing,
            initialData: _bloc.player.state.playing,
            builder: (context, snapshot) {
              final bool playing = snapshot.data ?? false;
              return IconButton(
                icon: Icon(
                  playing
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  size: 40,
                ),
                color: Colors.white,
                tooltip: playing ? l10n.pause : l10n.play,
                onPressed: () {
                  _scheduleHide();
                  _bloc.add(const PlayerTogglePlayRequested());
                },
              );
            },
          ),
          IconButton(
            tooltip: l10n.subtitles,
            icon: const Icon(Icons.subtitles, color: Colors.white, size: 28),
            onPressed: () {
              _cancelHide();
              setState(() => _picker = _TrackPickerMode.subtitles);
            },
          ),
          const Spacer(),
          StreamBuilder<double>(
            stream: _bloc.player.stream.volume,
            initialData: _bloc.player.state.volume,
            builder: (context, snapshot) {
              final double volume = ((snapshot.data ?? 1.0) / 100.0).clamp(
                0.0,
                1.0,
              );
              return SizedBox(
                width: 130,
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.volume_up, color: Colors.white, size: 20),
                    Expanded(
                      child: Slider(
                        value: volume,
                        max: 1.0,
                        activeColor: AppColors.primary,
                        inactiveColor: Colors.white24,
                        onChangeStart: (_) => _cancelHide(),
                        onChangeEnd: (_) => _scheduleHide(),
                        onChanged: (double value) =>
                            _bloc.player.setVolume(value * 100.0),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            tooltip: _isFullscreen ? l10n.exitFullscreen : l10n.fullscreen,
            icon: Icon(
              _isFullscreen
                  ? Icons.fullscreen_exit
                  : Icons.fullscreen,
              color: Colors.white,
            ),
            onPressed: _toggleFullscreen,
          ),
        ],
      ),
    );
  }

  /// selector en el centro de la pantalla con las pistas disponibles.
  ///
  /// Para pistas de audio muestra las pistas de audio activas; para subtítulos
  /// lista la opción "Off" más las pistas de subtítulos disponibles. El modo
  /// activo se define en [_picker].
  Widget _buildTrackPicker(AppLocalizations l10n) {
    final Tracks tracks = _bloc.player.state.tracks;
    final AudioTrack selectedAudio = _bloc.player.state.track.audio;
    final SubtitleTrack selectedSubtitle = _bloc.player.state.track.subtitle;
    final bool audioMode = _picker == _TrackPickerMode.audio;

    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() => _picker = null);
          _scheduleHide();
        },
        child: Container(
          color: Colors.black45,
          alignment: Alignment.center,
          child: Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 300,
                maxHeight: 340,
              ),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text(
                      audioMode ? l10n.audioTrack : l10n.subtitles,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  if (audioMode)
                    for (final AudioTrack track in tracks.audio)
                      _pickerTile(
                        label: _trackLabel(track.title, track.language),
                        selected: selectedAudio.id == track.id,
                        onTap: () {
                          setState(() => _picker = null);
                          _scheduleHide();
                          final AudioTrack? found = _firstOrNull<AudioTrack>(
                            tracks.audio,
                            (AudioTrack t) => t.id == track.id,
                          );
                          if (found != null) _bloc.player.setAudioTrack(found);
                        },
                      )
                  else ...<Widget>[
                    _pickerTile(
                      label: _trackLabel(null, 'Off'),
                      selected: selectedSubtitle.id == 'no',
                      onTap: () {
                        setState(() => _picker = null);
                        _scheduleHide();
                        _bloc.player.setSubtitleTrack(SubtitleTrack.no());
                      },
                    ),
                    for (final SubtitleTrack track in tracks.subtitle)
                      if (track.id != 'no' && track.id != 'auto')
                        _pickerTile(
                          label: _trackLabel(track.title, track.language),
                          selected: selectedSubtitle.id == track.id,
                          onTap: () {
                            setState(() => _picker = null);
                            _scheduleHide();
                            final SubtitleTrack? found = _firstOrNull<
                              SubtitleTrack
                            >(
                              tracks.subtitle,
                              (SubtitleTrack t) => t.id == track.id,
                            );
                            if (found != null) {
                              _bloc.player.setSubtitleTrack(found);
                            }
                          },
                        ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pickerTile({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      leading: Icon(
        selected ? Icons.check_circle : Icons.circle_outlined,
        size: 20,
        color: selected ? AppColors.secondary : AppColors.onSurfaceVariant,
      ),
      title: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: AppColors.onSurface),
      ),
      onTap: onTap,
    );
  }

  String _trackLabel(String? title, String? language) {
    if (title != null && title.isNotEmpty && title != 'auto') return title;
    if (language != null && language.isNotEmpty) return language;
    return 'auto';
  }

  static T? _firstOrNull<T>(List<T> items, bool Function(T) test) {
    for (final T item in items) {
      if (test(item)) return item;
    }
    return null;
  }

  String _formatPosition(Duration position) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(position.inHours)}:${two(position.inMinutes.remainder(60))}:'
        '${two(position.inSeconds.remainder(60))}';
  }
}

/// Superposición de error con opción de reintento.
class _ErrorOverlay extends StatelessWidget {
  const _ErrorOverlay({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.error_outline, size: 56, color: AppColors.error),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 12),
          FilledButton.tonal(onPressed: onRetry, child: Text(message)),
        ],
      ),
    );
  }
}
