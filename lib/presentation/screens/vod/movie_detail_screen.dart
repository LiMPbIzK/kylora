import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/media/playback_controller.dart';
import '../../../core/media/playback_request.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/repositories/iptv_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared_widgets/media_poster.dart';
import '../player/playback_scope.dart';

/// Detalle de una película con póster, meta y botón de reproducción.
class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movie});

  final Movie movie;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  /// Foco del botón Reproducir: al abrir la ficha en TV debe quedar ahí para
  /// poder iniciar la película pulsando directamente OK.
  final FocusNode _playFocusNode = FocusNode(debugLabel: 'movie-play');

  PlaybackController? _playback;
  bool _wasPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _playFocusNode.requestFocus();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final PlaybackController controller = PlaybackScope.of(context);
    if (!identical(controller, _playback)) {
      _playback?.removeListener(_onPlaybackChanged);
      _playback = controller..addListener(_onPlaybackChanged);
      _wasPlaying = controller.isPlaying;
    }
  }

  /// Al cerrar el reproductor, devuelve el foco al botón Reproducir para que el
  /// D-Pad siga funcionando en la ficha (solo si el overlay no lo restauró).
  void _onPlaybackChanged() {
    final bool playing = _playback?.isPlaying ?? false;
    if (playing == _wasPlaying) return;
    _wasPlaying = playing;
    if (playing) return;
    Future<void>.delayed(const Duration(milliseconds: 220), () {
      if (!mounted) return;
      if (ModalRoute.of(context)?.isCurrent != true) return;
      if (FocusScope.of(context).hasFocus) return;
      _playFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _playback?.removeListener(_onPlaybackChanged);
    _playFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final Movie movie = widget.movie;

    return Scaffold(
      appBar: AppBar(title: Text(movie.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 140,
                height: 210,
                child: MediaPoster(
                  url: movie.streamIcon,
                  fallbackIcon: Icons.movie,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      movie.name,
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (movie.rating != null) ...<Widget>[
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.star,
                            size: 18,
                            color: context.colors.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(movie.rating!),
                        ],
                      ),
                    ],
                    if ((movie.containerExtension ?? '')
                        .isNotEmpty) ...<Widget>[
                      const SizedBox(height: 4),
                      Text(movie.containerExtension!.toUpperCase()),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            autofocus: true,
            focusNode: _playFocusNode,
            icon: const Icon(Icons.play_arrow),
            label: Text(l10n.play),
            onPressed: () {
              final IptvRepository repository = context.read<IptvRepository>();
              PlaybackScope.of(context).play(
                PlaybackRequest(
                  title: movie.name,
                  urlBuilder: () => repository.buildVodStreamUrl(movie),
                  contentType: 'vod',
                  contentId: movie.id,
                  logo: movie.streamIcon,
                ),
              );
            },
          ),
          if (movie.rating5Based != null) ...<Widget>[
            const SizedBox(height: 16),
            Text(
              '${l10n.rating}: ${movie.rating5Based}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}
