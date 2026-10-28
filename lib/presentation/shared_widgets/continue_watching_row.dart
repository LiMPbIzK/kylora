import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/media/playback_request.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/content_type.dart';
import '../../../domain/entities/history_item.dart';
import '../../../l10n/app_localizations.dart';
import '../blocs/history/history_bloc.dart';
import '../blocs/history/history_state.dart';
import '../screens/player/playback_scope.dart';
import 'media_poster.dart';
import 'tv_focusable.dart';
import 'tv_marquee_text.dart';

/// Fila de "Continuar visualización" en el selector de inicio.
class ContinueWatchingRow extends StatelessWidget {
  const ContinueWatchingRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        if (state is! HistoryLoaded) return const SizedBox.shrink();
        final List<HistoryItem> items =
            state.items.where(_shouldResume).toList()..sort(
              (HistoryItem a, HistoryItem b) =>
                  b.watchedAt.compareTo(a.watchedAt),
            );
        if (items.isEmpty) return const SizedBox.shrink();
        final AppLocalizations l10n = AppLocalizations.of(context)!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                l10n.continueWatchingSection,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 210,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (BuildContext context, int index) {
                  return _ContinueCard(item: items[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  static bool _shouldResume(HistoryItem item) {
    if (item.contentType == ContentType.live) return false;
    if (item.position <= 0) return false;
    final int? duration = item.duration;
    if (duration == null || duration <= 0) return false;
    if (item.streamUrl == null || item.streamUrl!.isEmpty) return false;
    final double progress = item.position / duration;
    return progress >= 0.02 && progress <= 0.95;
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.item});

  final HistoryItem item;

  @override
  Widget build(BuildContext context) {
    final int duration = item.duration ?? item.position + 1;
    final double progress = (item.position / duration).clamp(0.0, 1.0);
    final ContentType type = item.contentType;
    final String? url = item.streamUrl;

    void resume() {
      if (url == null || url.isEmpty) return;
      PlaybackScope.of(context).play(
        PlaybackRequest(
          title: item.name,
          urlBuilder: () async => url,
          contentType: item.contentType.name,
          contentId: item.contentId,
          startPosition: Duration(seconds: item.position),
          logo: item.logo,
        ),
      );
    }

    return SizedBox(
      width: 156,
      child: TvFocusable(
        onPressed: resume,
        borderRadius: BorderRadius.circular(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: MediaPoster(
                  url: item.logo,
                  fallbackIcon: type == ContentType.vod
                      ? Icons.movie
                      : Icons.theaters,
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 34,
              child: TvMarqueeText(
                text: item.name,
                maxLines: 2,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              borderRadius: BorderRadius.circular(2),
              backgroundColor: context.colors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(context.colors.primary),
            ),
            const SizedBox(height: 3),
            Text(
              '${_fmt(item.position)} / ${_fmt(duration)}',
              maxLines: 1,
              style: TextStyle(
                color: context.colors.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmt(int seconds) {
    final int h = seconds ~/ 3600;
    final int m = (seconds % 3600) ~/ 60;
    final int s = seconds % 60;
    final String mm = m.toString().padLeft(2, '0');
    final String ss = s.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
  }
}
