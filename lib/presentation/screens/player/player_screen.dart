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

class _PlayerScreenState extends State<PlayerScreen> {
  late final VideoController _videoController;
  late final PlayerBloc _bloc;
  Timer? _hideTimer;
  bool _osdVisible = true;
  String _title = '';

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

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _hideTimer?.cancel();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              Video(controller: _videoController),
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
                      onRetry: () => _bloc.add(const PlayerRetryRequested()),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              if (_osdVisible) _buildOsd(),
            ],
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
                  _buildTracksMenu(l10n),
                ],
              ),
              const Spacer(),
              _buildControlBar(l10n),
            ],
          ),
        ),
      ),
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
          StreamBuilder<Duration>(
            stream: _bloc.player.stream.position,
            initialData: _bloc.player.state.position,
            builder: (context, snapshot) {
              final Duration position = snapshot.data ?? Duration.zero;
              return Text(
                _formatPosition(position),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              );
            },
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.pause_circle_filled, size: 40),
            color: Colors.white,
            onPressed: () {
              _scheduleHide();
              _bloc.add(const PlayerTogglePlayRequested());
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
        ],
      ),
    );
  }

  /// Menú con las pistas de audio y subtítulos disponibles.
  Widget _buildTracksMenu(AppLocalizations l10n) {
    return StreamBuilder<Tracks>(
      stream: _bloc.player.stream.tracks,
      initialData: _bloc.player.state.tracks,
      builder: (context, snapshot) {
        final Tracks tracks = snapshot.data ?? const Tracks();
        final AudioTrack selectedAudio = _bloc.player.state.track.audio;
        final SubtitleTrack selectedSubtitle =
            _bloc.player.state.track.subtitle;

        return PopupMenuButton<String>(
          tooltip: l10n.settings,
          icon: const Icon(Icons.more_vert, color: Colors.white),
          color: AppColors.surface,
          onSelected: (String value) {
            _scheduleHide();
            if (value.startsWith('audio:')) {
              final String id = value.substring('audio:'.length);
              final AudioTrack? track = _firstOrNull<AudioTrack>(
                tracks.audio,
                (AudioTrack t) => t.id == id,
              );
              if (track != null) {
                _bloc.player.setAudioTrack(track);
              }
            } else if (value.startsWith('sub:')) {
              final String id = value.substring('sub:'.length);
              if (id == 'no') {
                _bloc.player.setSubtitleTrack(SubtitleTrack.no());
              } else {
                final SubtitleTrack? track = _firstOrNull<SubtitleTrack>(
                  tracks.subtitle,
                  (SubtitleTrack t) => t.id == id,
                );
                if (track != null) {
                  _bloc.player.setSubtitleTrack(track);
                }
              }
            }
          },
          itemBuilder: (context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              enabled: false,
              child: Text(
                l10n.audioTrack,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            for (final AudioTrack track in tracks.audio)
              PopupMenuItem<String>(
                value: 'audio:${track.id}',
                child: _trackRow(
                  label: _trackLabel(track.title, track.language),
                  selected: selectedAudio.id == track.id,
                ),
              ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              enabled: false,
              child: Text(
                l10n.subtitles,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            PopupMenuItem<String>(
              value: 'sub:no',
              child: _trackRow(
                label: _trackLabel(null, 'Off'),
                selected: selectedSubtitle.id == 'no',
              ),
            ),
            for (final SubtitleTrack track in tracks.subtitle)
              if (track.id != 'no' && track.id != 'auto')
                PopupMenuItem<String>(
                  value: 'sub:${track.id}',
                  child: _trackRow(
                    label: _trackLabel(track.title, track.language),
                    selected: selectedSubtitle.id == track.id,
                  ),
                ),
          ],
        );
      },
    );
  }

  Widget _trackRow({required String label, required bool selected}) {
    return Row(
      children: <Widget>[
        if (selected)
          const Icon(Icons.check, size: 20, color: AppColors.secondary)
        else
          const Icon(Icons.north_west, size: 0, color: Colors.transparent),
        const SizedBox(width: 8),
        Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
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
