import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/repositories/iptv_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared_widgets/media_poster.dart';
import '../player/playback_request.dart';

/// Detalle de una película con póster, meta y botón de reproducción.
class MovieDetailScreen extends StatelessWidget {
  const MovieDetailScreen({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

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
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (movie.rating != null) ...<Widget>[
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          const Icon(Icons.star, size: 18, color: AppColors.secondary),
                          const SizedBox(width: 4),
                          Text(movie.rating!),
                        ],
                      ),
                    ],
                    if ((movie.containerExtension ?? '').isNotEmpty) ...<Widget>[
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
            icon: const Icon(Icons.play_arrow),
            label: Text(l10n.play),
            onPressed: () {
              final IptvRepository repository =
                  context.read<IptvRepository>();
              context.push(
                Routes.play,
                extra: PlaybackRequest(
                  title: movie.name,
                  urlBuilder: () => repository.buildVodStreamUrl(movie),
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
