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
import '../../../domain/entities/epg.dart';
import '../../../domain/entities/history_item.dart';
import '../../../domain/repositories/iptv_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../blocs/epg/epg_bloc.dart';
import '../../blocs/epg/epg_event.dart';
import '../../blocs/epg/epg_state.dart';
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
  late final PlayerBloc _bloc;
  late final VideoController _videoController;
  Timer? _hideTimer;
  bool _osdVisible = true;
  bool _isFullscreen = false;
  String _title = '';
  int? _liveContentId;
  bool _guideOpen = false;
  _TrackPickerMode? _picker;
  StreamSubscription<Tracks>? _tracksSubscription;
  bool _audioPreferenceApplied = false;
  bool _audioPreferenceBlocked = false;
  Timer? _historyTimer;
  PlaybackRequest? _historyRequest;

  /// Intervalo de persistencia del progreso de reproducción.
  static const Duration _historyInterval = Duration(seconds: 15);

  /// Códigos de idioma (ISO-639-1/2 y nombres) aceptados por pista de audio,
  /// agrupados por el idioma de la aplicación.
  static const Map<String, List<String>> _audioLanguageCodes = <String, List<String>>{
    'es': <String>['es', 'spa', 'esp', 'cast', 'castellano', 'español'],
    'en': <String>['en', 'eng', 'ing', 'ingles', 'inglés', 'english'],
    'fr': <String>['fr', 'fra', 'fre', 'frances', 'francés', 'french'],
    'de': <String>['de', 'ger', 'deu', 'aleman', 'alemán', 'german'],
    'it': <String>['it', 'ita', 'ital', 'italian'],
    'pt': <String>['pt', 'por', 'portug', 'portugués'],
  };

  @override
  void initState() {
    super.initState();
    // Un único bloc/player para toda la sesión (no se recrea por navegación).
    _bloc = PlayerBloc(AppPlayer.instance.player);
    _videoController = VideoController(_bloc.player);
    widget.controller.addListener(_onControllerChanged);
    _tracksSubscription = _bloc.player.stream.tracks.listen(_onTracksChanged);
    _onControllerChanged();
  }

  /// Selecciona la pista de audio por defecto según el idioma de la aplicación.
  ///
  /// Si ninguna pista coincide con el idioma de la app, se deja la primera
  /// disponible (comportamiento por defecto de media_kit). Se ignora cuando el
  /// usuario elige manualmente la pista desde el OSD.
  void _onTracksChanged(Tracks tracks) {
    if (!mounted || _audioPreferenceApplied || _audioPreferenceBlocked) return;
    _audioPreferenceApplied = true;
    final List<AudioTrack> audio = tracks.audio;
    if (audio.isEmpty) return;
    final String? appLang = Localizations.maybeLocaleOf(context)?.languageCode;
    if (appLang == null) return;
    final AudioTrack? match = _matchAudioTrack(audio, appLang);
    if (match != null) {
      _bloc.player.setAudioTrack(match);
    }
  }

  AudioTrack? _matchAudioTrack(List<AudioTrack> audio, String appLang) {
    final List<String> codes = _audioLanguageCodes[appLang] ?? <String>[appLang];
    for (final AudioTrack track in audio) {
      final String lang = (track.language ?? '').toLowerCase();
      final String title = (track.title ?? '').toLowerCase();
      final bool match = codes.any(
        (String code) =>
            lang.contains(code) ||
            lang.split('-').first.contains(code) ||
            title.contains(code),
      );
      if (match) return track;
    }
    return null;
  }

  void _onControllerChanged() {
    final PlaybackRequest? request = widget.controller.current;
    if (request == null) {
      if (!_bloc.isClosed) _bloc.player.stop();
      return;
    }
    final bool needsPlay = _title != request.title || _bloc.streamUrl == null;
    final int? liveId = request.contentType == 'live' ? request.contentId : null;
    final bool wantsGuide = request.openGuide;
    if (needsPlay || _liveContentId != liveId || _guideOpen != wantsGuide) {
      // En directo, pide el EPG corto (ahora/siguiente) del canal reproducido
      // para que el OSD muestre la programación aunque la rejilla no lo haya
      // solicitado (p. ej. al reproducir desde el menú contextual).
      if (liveId != null) {
        context.read<EpgBloc>().add(EpgNowNextRequested(liveId));
      }
      setState(() {
        _title = request.title;
        _liveContentId = liveId;
        _guideOpen = wantsGuide;
      });
      if (needsPlay) {
        _audioPreferenceApplied = false;
        _audioPreferenceBlocked = false;
        _bloc.add(
          PlayerPlayRequested(
            request.urlBuilder,
            startPosition: request.startPosition,
          ),
        );
        _recordHistory(request);
      }
    }
  }

void _recordHistory(PlaybackRequest request) {
    if (request.contentType == null || request.contentId == null) return;
    // El directo en vivo no tiene sentido de progreso.
    if (request.contentType == 'live') return;
    _historyRequest = request;
    _updateHistory(request);
    // Persistencia periódica del progreso (si la app se cierra de golpe, el
    // último tick queda guardado). Se cancela al cerrar/reproducir otro.
    _historyTimer?.cancel();
    _historyTimer = Timer.periodic(_historyInterval, (_) {
      if (mounted) _updateHistory(request);
    });
  }

  /// Persiste (upsert) el estado de reproducción actual del contenido en curso.
  void _updateHistory(PlaybackRequest request) {
    final IptvRepository repository = context.read<IptvRepository>();
    final int positionSeconds = _bloc.player.state.position.inSeconds;
    final int durationSeconds = _bloc.player.state.duration.inSeconds;
    repository.addToHistory(
      HistoryItem(
        contentId: request.contentId!,
        contentType: ContentType.values.byName(request.contentType!),
        name: request.title,
        watchedAt: DateTime.now(),
        position: positionSeconds,
        duration: durationSeconds > 0 ? durationSeconds : null,
        streamUrl: _bloc.streamUrl,
      ),
    );
  }

  /// Guarda el progreso final y detiene la persistencia periódica.
  void _stopHistoryTracking() {
    _historyTimer?.cancel();
    _historyTimer = null;
    final PlaybackRequest? request = _historyRequest;
    if (request != null) {
      _updateHistory(request);
    }
    _historyRequest = null;
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
    _stopHistoryTracking();
    _bloc.player.stop();
    _bloc.resetContent();
    setState(() {
      _guideOpen = false;
      _liveContentId = null;
    });
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
    _tracksSubscription?.cancel();
    _hideTimer?.cancel();
    _stopHistoryTracking();
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
                      return Center(
                        child: CircularProgressIndicator(
                          color: context.colors.primary,
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
                if (_guideOpen && _liveContentId != null)
                  _buildEmbeddedGuide(
                    AppLocalizations.of(context)!,
                    _liveContentId!,
                  ),
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
                  if (_liveContentId != null)
                    _buildLiveEpgBar(l10n, _liveContentId!)
                  else
                    _buildProgressBar(l10n),
                  _buildControlBar(l10n),
                ],
              ),
        ),
      ),
    );
  }

  /// Línea del OSD para directo: muestra el programa actual y siguiente del
  /// canal en reproducción, junto a un acceso a la guía embebida.
  Widget _buildLiveEpgBar(AppLocalizations l10n, int streamId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: BlocBuilder<EpgBloc, EpgState>(
        buildWhen: (previous, current) =>
            current is EpgNowNextLoaded && current.streamId == streamId,
        builder: (context, state) {
          if (state is! EpgNowNextLoaded || state.streamId != streamId) {
            return const SizedBox.shrink();
          }
          final String now = state.now?.title ?? '—';
          final String next = state.next?.title ?? '—';
          return Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${l10n.nowEpg}: $now   ·   ${l10n.nextEpg}: $next',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
              if (state.hasGuide)
                IconButton(
                  tooltip: l10n.epgGuide,
                  icon: const Icon(Icons.calendar_view_day),
                  color: Colors.white,
                  onPressed: () {
                    _scheduleHide();
                    setState(() => _guideOpen = true);
                    _liveContentId ??= streamId;
                  },
                ),
            ],
          );
        },
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
                    activeColor: context.colors.primary,
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
                        activeColor: context.colors.primary,
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

  /// Guía embebida del canal en directo: overlay dentro del reproductor que
  /// muestra la programación completa mientras el stream sigue reproduciendo.
  Widget _buildEmbeddedGuide(AppLocalizations l10n, int streamId) {
    // Dispara la carga de la programación completa si aún no está en caché.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<EpgBloc>().add(EpgGuideRequested(streamId, _title));
      }
    });

    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() => _guideOpen = false);
          _scheduleHide();
        },
        child: Container(
          color: Colors.black87,
          alignment: Alignment.center,
          child: Material(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640, maxHeight: 500),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.calendar_view_day,
                          color: context.colors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.epgGuide,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: context.colors.onSurface,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.close,
                          icon: Icon(
                            Icons.close,
                            color: context.colors.onSurface,
                          ),
                          onPressed: () {
                            setState(() => _guideOpen = false);
                            _scheduleHide();
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: BlocBuilder<EpgBloc, EpgState>(
                      buildWhen: (previous, current) => switch (current) {
                        EpgGuideLoaded() => current.streamId == streamId,
                        EpgLoading() => current.streamId == streamId,
                        EpgEmpty() => current.streamId == streamId,
                        EpgFailure() => current.streamId == streamId,
                        _ => false,
                      },
                      builder: (context, state) {
                        switch (state) {
                          case EpgGuideLoaded() when state.streamId == streamId:
                            return state.entries.isEmpty
                                ? Center(child: Text(l10n.epgNoProgram))
                                : _buildGuideList(state.entries);
                          case EpgLoading() when state.streamId == streamId:
                          case EpgEmpty() when state.streamId == streamId:
                            return Center(child: Text(l10n.epgNoProgram));
                          case EpgFailure() when state.streamId == streamId:
                            return Center(child: Text(l10n.epgLoadError));
                          default:
                            return Center(
                              child: CircularProgressIndicator(
                                color: context.colors.primary,
                              ),
                            );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuideList(List<EpgEntry> entries) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final EpgEntry entry = entries[index];
        return _GuideTile(
          entry: entry,
          isOnAir: entry.isOnAir(DateTime.now()),
        );
      },
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
            color: context.colors.surface,
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: context.colors.onSurface,
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
                          _audioPreferenceBlocked = true;
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
        color: selected
            ? context.colors.secondary
            : context.colors.onSurfaceVariant,
      ),
      title: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: context.colors.onSurface),
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
          Icon(Icons.error_outline, size: 56, color: context.colors.error),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 12),
          FilledButton.tonal(onPressed: onRetry, child: Text(message)),
        ],
      ),
    );
  }
}

/// Fila de programa de la guía embebida, con el actual resaltado.
class _GuideTile extends StatelessWidget {
  const _GuideTile({required this.entry, required this.isOnAir});

  final EpgEntry entry;
  final bool isOnAir;

  @override
  Widget build(BuildContext context) {
    final String time = '${_two(entry.start.hour)}:${_two(entry.start.minute)}'
        ' - ${_two(entry.end.hour)}:${_two(entry.end.minute)}';
    final AppColors colors = context.colors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isOnAir ? colors.primaryContainer : colors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 78,
            child: Text(
              time,
              style: TextStyle(
                color: isOnAir ? colors.primary : colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  entry.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: isOnAir
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                if (entry.description?.isNotEmpty == true) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    entry.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}
