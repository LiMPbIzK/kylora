import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/media/playback_request.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/content_type.dart';
import '../../../domain/entities/history_item.dart';
import '../../../domain/repositories/iptv_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../screens/player/playback_scope.dart';
import 'media_poster.dart';
import 'tv_focusable.dart';

/// Fila dinámica "Continuar visualización".
///
/// Muestra el contenido VOD/Series en progreso (posición guardada) con una
/// barra de progreso por tarjeta. Al pulsar, reanuda la reproducción en el
/// punto donde quedó.
class ResumeRow extends StatelessWidget {
  const ResumeRow({super.key, required this.contentType});

  /// Qué tipo de contenido se filtra ('vod' o 'series').
  final String contentType;

  /// Fracción mínima de duración consumida para considerarlo "en curso"
  /// (evita mostrar segundos con lo apenas iniciado).
  static const double _minProgress = 0.02;

  /// Fracción máxima: si ya se vio casi todo, no merece reanudar.
  static const double _maxProgress = 0.95;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return FutureBuilder<List<HistoryItem>>(
      future: context.read<IptvRepository>().getHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }
        final List<HistoryItem> items = (snapshot.data ?? <HistoryItem>[])
            .where((HistoryItem item) => _shouldResume(item))
            .toList();
        if (items.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                l10n.continueWatchingSection,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 168,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) =>
                      _ResumeCard(item: items[index]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _shouldResume(HistoryItem item) {
    if (item.contentType.name != contentType) return false;
    if (item.position <= 0) return false;
    final int? duration = item.duration;
    if (duration == null || duration <= 0) return false;
    final double progress = item.position / duration;
    return progress >= _minProgress && progress <= _maxProgress;
  }
}

/// Tarjeta de contenido en progreso: póster, título y barra de progreso.
class _ResumeCard extends StatelessWidget {
  const _ResumeCard({required this.item});

  final HistoryItem item;

  @override
  Widget build(BuildContext context) {
    final int duration = item.duration ?? item.position + 1;
    final double progress = (item.position / duration).clamp(0.0, 1.0);
    final ContentType type = item.contentType;

    return TvFocusable(
      borderRadius: BorderRadius.circular(8),
      onPressed: () {
        final String? url = item.streamUrl;
        if (url == null || url.isEmpty) return;
        PlaybackScope.of(context).play(
          PlaybackRequest(
            title: item.name,
            urlBuilder: () async => url,
            contentType: item.contentType.name,
            contentId: item.contentId,
            startPosition: Duration(seconds: item.position),
          ),
        );
      },
      child: SizedBox(
        width: 128,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 2 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: MediaPoster(
                  url: item.logo,
                  fallbackIcon: type == ContentType.vod
                      ? Icons.movie
                      : Icons.theaters,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: context.colors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(context.colors.primary),
            ),
            const SizedBox(height: 2),
            Text(
              '${_fmt(item.position)} / ${_fmt(duration)}',
              maxLines: 1,
              style: TextStyle(
                fontSize: 11,
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int seconds) {
    final int h = seconds ~/ 3600;
    final int m = (seconds % 3600) ~/ 60;
    final int s = seconds % 60;
    final String mm = m.toString().padLeft(2, '0');
    final String ss = s.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
  }
}