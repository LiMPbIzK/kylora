import 'dart:async';

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show HardwareKeyboard, KeyDownEvent, KeyEvent, LogicalKeyboardKey;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart' hide PlayerState;
import 'package:media_kit_video/media_kit_video.dart';

import '../../../core/media/app_player.dart';
import '../../../core/media/playback_controller.dart';
import '../../../core/media/playback_request.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/clock_format.dart';
import '../../../core/utils/playback_time.dart';
import '../../../core/utils/video_resolution.dart';
import '../../../domain/entities/content_type.dart';
import '../../../domain/entities/epg.dart';
import '../../../domain/entities/history_item.dart';
import '../../../domain/repositories/iptv_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../blocs/epg/epg_bloc.dart';
import '../../blocs/epg/epg_event.dart';
import '../../blocs/epg/epg_state.dart';
import '../../blocs/history/history_bloc.dart';
import '../../blocs/history/history_event.dart';
import '../../blocs/player/player_bloc.dart';
import '../../blocs/player/player_event.dart';
import '../../blocs/player/player_state.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../blocs/settings/settings_state.dart';
import '../../shared_widgets/program_guide_list.dart';
import 'playback_scope.dart';

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
  String? _contentType;
  bool _hasArchive = false;
  int? _archiveDurationDays;
  String _channelTitle = '';
  bool _guideOpen = false;
  final FocusNode _guideCloseFocusNode = FocusNode(debugLabel: 'guide-close');
  final FocusScopeNode _guideScopeNode = FocusScopeNode(debugLabel: 'guide');
  _TrackPickerMode? _picker;
  StreamSubscription<Tracks>? _tracksSubscription;
  bool _audioPreferenceApplied = false;
  bool _audioPreferenceBlocked = false;
  bool _subtitlePreferenceApplied = false;
  bool _subtitlePreferenceBlocked = false;
  Timer? _historyTimer;
  PlaybackRequest? _historyRequest;
  Duration? _lastStartPosition;
  final Map<String, String> _streamUrlCache = <String, String>{};

  /// Foco del control principal del OSD (play/pausa): al mostrar el OSD se le
  /// da el foco para que el mando pueda navegar por los controles.
  final FocusNode _osdFocusNode = FocusNode();

  /// Scope de los controles del OSD: permite saber si el foco está en alguno de
  /// ellos para no robarlo al volver a mostrar el OSD.
  final FocusScopeNode _osdScopeNode = FocusScopeNode(debugLabel: 'osd');

  /// Foco del selector de pistas (audio/subtítulos): al abrirlo se le da el
  /// foco al primer elemento para que el mando navegue dentro del selector y
  /// no por el OSD o el catálogo que quedan detrás.
  final FocusNode _pickerFocusNode = FocusNode(debugLabel: 'track-picker');

  /// Intervalo de persistencia del progreso de reproducción.
  static const Duration _historyInterval = Duration(seconds: 15);

  /// Códigos de idioma (ISO-639-1/2 y nombres) aceptados por pista de audio,
  /// agrupados por el idioma de la aplicación.
  static const Map<String, List<String>> _audioLanguageCodes =
      <String, List<String>>{
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
    // En Android (TV/móvil) se fuerza la decodificación por hardware. El modo
    // `auto-safe` puede caer a software con HEVC/4K; `auto` usa MediaCodec,
    // pero en algunos Android TV el camino zero-copy con dmabuf está bloqueado
    // por SELinux (se ven `avc: denied ... dev="dmabuf"` en logcat). Por eso se
    // usa `mediacodec_embed`: la salida va directa a la superficie del decodificador,
    // sin textura intermedia de GPU, que en Mali provocaba tirones en 4K.
    _videoController = VideoController(
      _bloc.player,
      configuration: defaultTargetPlatform == TargetPlatform.android
          ? const VideoControllerConfiguration(
              vo: 'mediacodec_embed',
              hwdec: 'mediacodec',
              enableHardwareAcceleration: true,
            )
          : const VideoControllerConfiguration(),
    );
    widget.controller.addListener(_onControllerChanged);
    _tracksSubscription = _bloc.player.stream.tracks.listen(_onTracksChanged);
    // Intercepta el botón Atrás del mando/TV mientras hay reproducción:
    // primera pulsación oculta el OSD; la segunda cierra el reproductor.
    widget.controller.onPlayerBack = () {
      if (!mounted) return false;
      // Con un selector abierto, Atrás lo cierra (no cierra el reproductor).
      if (_picker != null) {
        _closePicker();
        return true;
      }
      if (_guideOpen) {
        _closeGuide();
        return true;
      }
      if (_osdVisible) {
        setState(() => _osdVisible = false);
        return true;
      }
      // No consume: el llamante (HomeShell) cerrará el reproductor.
      return false;
    };
    // Captura el botón OK/selección del mando para mostrar el OSD mientras se
    // reproduce (sin depender del foco, que puede no estar en ningún control).
    HardwareKeyboard.instance.addHandler(_onHardwareKey);
    _onControllerChanged();
  }

  /// Handler global de teclas: con reproducción activa y el OSD oculto, el
  /// botón de selección/OK del mando muestra el OSD. Con el OSD visible no se
  /// consume, para que los controles enfocados reciban la pulsación.
  bool _onHardwareKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (!mounted) return false;
    if (!widget.controller.isPlaying) return false;
    final LogicalKeyboardKey key = event.logicalKey;
    final bool isSelect =
        key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.gameButtonA;
    if (!isSelect) return false;
    if (_guideOpen) return false;
    if (!_osdVisible) {
      _showOsd();
      return true;
    }
    return false;
  }

  /// Selecciona la pista de audio por defecto según el idioma de la aplicación.
  ///
  /// Si ninguna pista coincide con el idioma de la app, se deja la primera
  /// disponible (comportamiento por defecto de media_kit). Se ignora cuando el
  /// usuario elige manualmente la pista desde el OSD.
  void _onTracksChanged(Tracks tracks) {
    if (!mounted) return;
    final SettingsState settingsState = context.read<SettingsBloc>().state;
    final SettingsLoaded? settings = settingsState is SettingsLoaded
        ? settingsState
        : null;
    final String? preferredLanguage =
        settings?.audioLanguage ??
        Localizations.maybeLocaleOf(context)?.languageCode;

    if (!_audioPreferenceApplied && !_audioPreferenceBlocked) {
      _audioPreferenceApplied = true;
      if (preferredLanguage != null && tracks.audio.isNotEmpty) {
        final AudioTrack? match = _matchAudioTrack(
          tracks.audio,
          preferredLanguage,
        );
        if (match != null) {
          _bloc.player.setAudioTrack(match);
        }
      }
    }

    if (!_subtitlePreferenceApplied && !_subtitlePreferenceBlocked) {
      _subtitlePreferenceApplied = true;
      if (settings?.subtitlesEnabled == true && preferredLanguage != null) {
        final SubtitleTrack? match = _matchSubtitleTrack(
          tracks.subtitle,
          preferredLanguage,
        );
        _bloc.player.setSubtitleTrack(match ?? SubtitleTrack.no());
      } else {
        _bloc.player.setSubtitleTrack(SubtitleTrack.no());
      }
    }
  }

  SubtitleTrack? _matchSubtitleTrack(
    List<SubtitleTrack> subtitles,
    String language,
  ) {
    final List<String> codes =
        _audioLanguageCodes[language] ?? <String>[language];
    for (final SubtitleTrack track in subtitles) {
      if (track.id == 'no' || track.id == 'auto') continue;
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

  AudioTrack? _matchAudioTrack(List<AudioTrack> audio, String appLang) {
    final List<String> codes =
        _audioLanguageCodes[appLang] ?? <String>[appLang];
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
      if (_contentType != null) {
        setState(() {
          _contentType = null;
          _hasArchive = false;
          _archiveDurationDays = null;
          _channelTitle = '';
        });
      }
      if (!_bloc.isClosed) _bloc.player.stop();
      return;
    }
    // Se reproduce si el contenido cambió, o si no hay URL cargada todavía, o
    // si se pide reanudar desde una posición (mismo título pero nueva petición
    // con startPosition: reanudar a otra posición o re-iniciar).
    final bool resuming = request.startPosition != null;
    final bool needsPlay =
        _title != request.title ||
        _bloc.streamUrl == null ||
        _lastStartPosition != request.startPosition ||
        (resuming && _bloc.streamUrl != null);
    final int? liveId = request.contentType == 'live'
        ? request.contentId
        : null;
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
        _contentType = request.contentType;
        _hasArchive = request.hasArchive;
        _archiveDurationDays = request.archiveDurationDays;
        _channelTitle = request.channelTitle ?? request.title;
      });
      // Al iniciar la reproducción, muestra el OSD y programa su ocultado
      // automático (en TV no hay ratón que dispare `onHover`).
      if (needsPlay) _showOsd();
      if (needsPlay) {
        _lastStartPosition = request.startPosition;
        _audioPreferenceApplied = false;
        _audioPreferenceBlocked = false;
        _subtitlePreferenceApplied = false;
        _subtitlePreferenceBlocked = false;
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
    // Resuelve la URL del stream cuanto antes (la primera escritura sale con
    // streamUrl nulo) para poder reanudar.
    _primeStreamUrl(request);
    // Persistencia periódica del progreso (si la app se cierra de golpe, el
    // último tick queda guardado). Se cancela al cerrar/reproducir otro.
    _historyTimer?.cancel();
    _historyTimer = Timer.periodic(_historyInterval, (_) {
      if (mounted) _updateHistory(request);
    });
  }

  /// Persiste (upsert) el estado de reproducción actual del contenido en curso.
  ///
  /// La URL del stream se resuelve con [PlaybackRequest.urlBuilder] (no del
  /// player, que aún está a null durante la apertura asíncrona) para que el
  /// historial guarde siempre una URL reanudable. Si el contenido ya está casi
  /// visto (>= 95% de duración), se elimina del historial temporal en lugar de
  /// guardar el progreso (no tiene sentido "continuar" algo terminado).
  void _updateHistory(PlaybackRequest request) {
    final IptvRepository repository = context.read<IptvRepository>();
    final int positionSeconds = _bloc.player.state.position.inSeconds;
    final int durationSeconds = _bloc.player.state.duration.inSeconds;
    final String? url = _streamUrlCache[request.title] ?? _bloc.streamUrl;
    final ContentType type = ContentType.values.byName(request.contentType!);

    if (durationSeconds > 0 && positionSeconds >= durationSeconds * 0.95) {
      repository.removeFromHistory(request.contentId!, type);
      _historyRequest = null;
      _historyTimer?.cancel();
      return;
    }

    repository.addToHistory(
      HistoryItem(
        contentId: request.contentId!,
        contentType: type,
        name: request.title,
        logo: request.logo,
        watchedAt: DateTime.now(),
        position: positionSeconds,
        duration: durationSeconds > 0 ? durationSeconds : null,
        streamUrl: url,
      ),
    );
    // Guarda la URL resuelta para los ticks siguientes sin volver a resolverla.
    if (url != null) _streamUrlCache[request.title] = url;
  }

  /// Resuelve y cachea la URL del stream actual para el guardado de progreso.
  Future<void> _primeStreamUrl(PlaybackRequest request) async {
    if (_streamUrlCache.containsKey(request.title)) return;
    try {
      final String url = await request.urlBuilder();
      if (mounted) {
        _streamUrlCache[request.title] = url;
        if (_historyRequest == request) _updateHistory(request);
      }
    } catch (_) {
      // Sin URL no se puede reanudar; se reintentará en el siguiente tick.
    }
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
      if (!mounted || !_osdVisible) return;
      // No ocultar el OSD mientras hay un selector o la guía abiertos: si no,
      // el selector quedaría flotando sobre el vídeo sin sus controles.
      if (_picker != null || _guideOpen) return;
      setState(() => _osdVisible = false);
    });
  }

  /// Muestra el OSD, le da foco al control principal y programa su ocultado.
  ///
  /// Si el foco ya está en algún control del OSD (p. ej. el volumen), no se
  /// roba; si viene de fuera (inicio de reproducción, OSD recién mostrado) se
  /// enfoca play/pausa para que el mando tenga un punto de partida claro.
  void _showOsd() {
    if (!_osdVisible) {
      setState(() => _osdVisible = true);
    }
    _scheduleHide();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_osdVisible || _picker != null || _guideOpen) return;
      if (!_osdScopeNode.hasFocus) {
        _osdFocusNode.requestFocus();
      }
    });
  }

  /// Abre la guía embebida y lleva el foco a su X, para que el mando pueda
  /// cerrarla sin depender de la navegación por los controles del OSD.
  void _openGuide({int? streamId}) {
    _scheduleHide();
    setState(() {
      _guideOpen = true;
      if (streamId != null) _liveContentId ??= streamId;
    });
  }

  /// Cierra la guía embebida y devuelve el foco al OSD si sigue visible.
  void _closeGuide() {
    if (!_guideOpen) return;
    setState(() => _guideOpen = false);
    _scheduleHide();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _osdVisible) _osdFocusNode.requestFocus();
    });
  }

  /// Abre el selector de pistas y le da el foco al primer elemento.
  void _openPicker(_TrackPickerMode mode) {
    _cancelHide();
    setState(() => _picker = mode);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _pickerFocusNode.requestFocus();
    });
  }

  /// Cierra el selector de pistas y devuelve el foco al OSD.
  void _closePicker() {
    if (_picker == null) return;
    setState(() => _picker = null);
    _scheduleHide();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _osdVisible) {
        _osdFocusNode.requestFocus();
      }
    });
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
    context.read<HistoryBloc>().add(const HistoryStarted());
    setState(() {
      _guideOpen = false;
      _picker = null;
      _liveContentId = null;
      _contentType = null;
      _hasArchive = false;
      _archiveDurationDays = null;
      _channelTitle = '';
      _lastStartPosition = null;
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
    widget.controller.onPlayerBack = null;
    HardwareKeyboard.instance.removeHandler(_onHardwareKey);
    _osdFocusNode.dispose();
    _osdScopeNode.dispose();
    _guideCloseFocusNode.dispose();
    _guideScopeNode.dispose();
    _pickerFocusNode.dispose();
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
                        onRetry: () => _bloc.add(const PlayerRetryRequested()),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                if (_osdVisible)
                  // Con un selector abierto, los controles del OSD dejan de ser
                  // enfocables para que el D-Pad se quede dentro del selector.
                  ExcludeFocus(
                    excluding: _picker != null || _guideOpen,
                    child: FocusScope(node: _osdScopeNode, child: _buildOsd()),
                  ),
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
                    tooltip: l10n.close,
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
                  // Hora actual y fin de la reproducción (solo VOD/series),
                  // en la esquina superior derecha del OSD.
                  if (_contentType == 'vod' || _contentType == 'series')
                    _PlaybackClock(player: _bloc.player),
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
                  onPressed: () => _openGuide(streamId: streamId),
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
                      _bloc.player.seek(Duration(milliseconds: v.round()));
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

  /// Chip con la resolución real del vídeo (480p, 720p, 1080p...).
  Widget _buildResolutionChip() {
    return StreamBuilder<int?>(
      stream: _bloc.player.stream.height,
      initialData: _bloc.player.state.height,
      builder: (context, snapshot) {
        final int? height =
            snapshot.data ??
            _bloc.player.state.videoParams.dh ??
            _bloc.player.state.height;
        final String? label = videoResolutionLabel(height);
        if (label == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
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
            onPressed: () => _openPicker(_TrackPickerMode.audio),
          ),
          StreamBuilder<bool>(
            stream: _bloc.player.stream.playing,
            initialData: _bloc.player.state.playing,
            builder: (context, snapshot) {
              final bool playing = snapshot.data ?? false;
              return IconButton(
                focusNode: _osdFocusNode,
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
            onPressed: () => _openPicker(_TrackPickerMode.subtitles),
          ),
          const Spacer(),
          _buildResolutionChip(),
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
              _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
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
      child: FocusScope(
        node: _guideScopeNode,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _closeGuide,
          child: Container(
            color: Colors.black87,
            alignment: Alignment.center,
            child: Material(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 640,
                  maxHeight: 500,
                ),
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
                            focusNode: _guideCloseFocusNode,
                            tooltip: l10n.close,
                            icon: Icon(
                              Icons.close,
                              color: context.colors.onSurface,
                            ),
                            onPressed: _closeGuide,
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
                            case EpgGuideLoaded()
                                when state.streamId == streamId:
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
      ),
    );
  }

  Future<void> _playCatchupFromGuide(EpgEntry entry) async {
    final int? streamId = _liveContentId;
    if (streamId == null) return;
    final IptvRepository repository = context.read<IptvRepository>();
    final String? url = await repository.buildCatchupUrl(
      streamId: streamId,
      hasArchive: _hasArchive,
      archiveDurationDays: _archiveDurationDays,
      program: entry,
    );
    if (!mounted) return;
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.catchupUnavailable),
        ),
      );
      return;
    }
    _closeGuide();
    PlaybackScope.of(context).play(
      PlaybackRequest(
        title: '$_channelTitle · ${entry.title}',
        urlBuilder: () async => url,
        contentType: 'live',
        contentId: streamId,
        hasArchive: _hasArchive,
        archiveDurationDays: _archiveDurationDays,
        channelTitle: _channelTitle,
      ),
    );
  }

  Widget _buildGuideList(List<EpgEntry> entries) {
    return ProgramGuideList(
      entries: entries,
      hasArchive: _hasArchive,
      archiveDurationDays: _archiveDurationDays,
      onPlay: _playCatchupFromGuide,
      compact: true,
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

    // Tiles del selector. El primero recibe el foco al abrirlo para que el
    // mando navegue dentro del selector (no por el OSD ni el catálogo).
    final List<Widget> tiles = <Widget>[];
    void addTile({
      required String label,
      required bool selected,
      required VoidCallback onTap,
    }) {
      tiles.add(
        _pickerTile(
          label: label,
          selected: selected,
          onTap: onTap,
          focusNode: tiles.isEmpty ? _pickerFocusNode : null,
        ),
      );
    }

    if (audioMode) {
      for (final AudioTrack track in tracks.audio) {
        addTile(
          label: _trackLabel(track.title, track.language),
          selected: selectedAudio.id == track.id,
          onTap: () {
            _closePicker();
            _audioPreferenceBlocked = true;
            final AudioTrack? found = _firstOrNull<AudioTrack>(
              tracks.audio,
              (AudioTrack t) => t.id == track.id,
            );
            if (found != null) _bloc.player.setAudioTrack(found);
          },
        );
      }
    } else {
      addTile(
        label: _trackLabel(null, 'Off'),
        selected: selectedSubtitle.id == 'no',
        onTap: () {
          _closePicker();
          _subtitlePreferenceBlocked = true;
          _bloc.player.setSubtitleTrack(SubtitleTrack.no());
        },
      );
      for (final SubtitleTrack track in tracks.subtitle) {
        if (track.id == 'no' || track.id == 'auto') continue;
        addTile(
          label: _trackLabel(track.title, track.language),
          selected: selectedSubtitle.id == track.id,
          onTap: () {
            _closePicker();
            _subtitlePreferenceBlocked = true;
            final SubtitleTrack? found = _firstOrNull<SubtitleTrack>(
              tracks.subtitle,
              (SubtitleTrack t) => t.id == track.id,
            );
            if (found != null) _bloc.player.setSubtitleTrack(found);
          },
        );
      }
    }

    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _closePicker,
        child: Container(
          color: Colors.black45,
          alignment: Alignment.center,
          child: Material(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300, maxHeight: 340),
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
                  ...tiles,
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
    FocusNode? focusNode,
  }) {
    return ListTile(
      dense: true,
      focusNode: focusNode,
      autofocus: focusNode != null,
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

/// Reloj de reproducción (solo VOD/series): hora actual y hora estimada de fin.
///
/// Se muestra en la esquina superior derecha del OSD (fuera de la barra de
/// controles) y se oculta con él. La hora de fin se calcula siempre con la hora
/// actual: si el vídeo está en pausa, el tiempo restante no cambia pero el reloj
/// sí avanza, por lo que la hora de fin se desplaza hacia delante.
class _PlaybackClock extends StatefulWidget {
  const _PlaybackClock({required this.player});

  final Player player;

  @override
  State<_PlaybackClock> createState() => _PlaybackClockState();
}

class _PlaybackClockState extends State<_PlaybackClock> {
  late DateTime _now;
  DateTime? _endsAt;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _tick(notify: false);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick({bool notify = true}) {
    if (!mounted) return;
    final DateTime now = DateTime.now();
    final Duration duration = widget.player.state.duration;
    final Duration position = widget.player.state.position;
    // Sin condición de pausa: los minutos restantes son los que son, pero la
    // hora de fin depende de la hora actual (en pausa se va desplazando).
    final DateTime? endsAt = duration > Duration.zero
        ? playbackEndsAt(now: now, position: position, duration: duration)
        : null;
    if (!notify) {
      _now = now;
      _endsAt = endsAt;
      return;
    }
    setState(() {
      _now = now;
      _endsAt = endsAt;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(BuildContext context, DateTime value, bool clock24h) {
    return formatClockTime(
      TimeOfDay.fromDateTime(value),
      clock24h: clock24h,
      localizations: MaterialLocalizations.of(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final AppLocalizations l10n = AppLocalizations.of(context)!;
        final bool clock24h = state is SettingsLoaded ? state.clock24h : true;
        final String nowText = _format(context, _now, clock24h);
        final String? endText = _endsAt == null
            ? null
            : l10n.endsAt(_format(context, _endsAt!, clock24h));
        return Container(
          margin: const EdgeInsets.only(left: 8, right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                nowText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (endText != null) ...<Widget>[
                const SizedBox(height: 1),
                Text(
                  endText,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ],
          ),
        );
      },
    );
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
