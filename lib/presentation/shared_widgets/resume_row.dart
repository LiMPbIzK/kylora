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

/// Vista "Continuar visualización": rejilla de contenido en progreso.
///
/// Se selecciona desde la barra lateral (donde antes estaba "Todas"). Cada
/// tarjeta muestra póster, título, barra de progreso y tiempo. Al pulsar,
/// reanuda la reproducción donde quedó.
class ResumeGrid extends StatefulWidget {
  const ResumeGrid({super.key, required this.contentType});

  /// Tipo de contenido a filtrar ('vod' o 'series').
  final String contentType;

  /// Fracción mínima/máxima de progreso para considerar contenido "a medias".
  static const double _minProgress = 0.02;
  static const double _maxProgress = 0.95;

  @override
  State<ResumeGrid> createState() => _ResumeGridState();
}

class _ResumeGridState extends State<ResumeGrid> {
  int _revision = 0;

  @override
  Widget build(BuildContext context) {
    final String contentType = widget.contentType;
    return FutureBuilder<List<HistoryItem>>(
      future: context.read<IptvRepository>().getHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final List<HistoryItem> items = (snapshot.data ?? <HistoryItem>[])
            .where((HistoryItem item) => _shouldResume(item, contentType))
            .toList();
        if (items.isEmpty) {
          return Center(child: Text(AppLocalizations.of(context)!.noHistory));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.62,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => _ResumeCard(
            item: items[index],
            onRemoved: () => setState(() => _revision++),
          ),
        );
      },
    );
  }

  bool _shouldResume(HistoryItem item, String contentType) {
    if (item.contentType.name != contentType) return false;
    if (item.position <= 0) return false;
    if (item.streamUrl == null || item.streamUrl!.isEmpty) return false;
    final int? duration = item.duration;
    if (duration == null || duration <= 0) return false;
    final double progress = item.position / duration;
    return progress >= ResumeGrid._minProgress &&
        progress <= ResumeGrid._maxProgress;
  }
}

/// Tarjeta de contenido en progreso: póster, título y barra de progreso.
class _ResumeCard extends StatelessWidget {
  const _ResumeCard({required this.item, this.onRemoved});

  final HistoryItem item;

  /// Callback tras eliminar la entrada desde esta tarjeta.
  final VoidCallback? onRemoved;

  @override
  Widget build(BuildContext context) {
    final int duration = item.duration ?? item.position + 1;
    final double progress = (item.position / duration).clamp(0.0, 1.0);
    final ContentType type = item.contentType;
    final String? url = item.streamUrl;
    final bool playable = url != null && url.isNotEmpty;

    void resume() {
      if (!playable) return;
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

    Future<void> confirmRemove() async {
      final AppLocalizations l10n = AppLocalizations.of(context)!;
      final IptvRepository repository = context.read<IptvRepository>();
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.removeResumeTitle),
          content: Text(l10n.removeResumeConfirm),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.removeResumeConfirmButton),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        await repository.removeFromHistory(item.contentId, item.contentType);
        onRemoved?.call();
      }
    }

    return TvFocusable(
      borderRadius: BorderRadius.circular(8),
      onPressed: resume,
      child: GestureDetector(
        onTap: resume,
        onLongPress: confirmRemove,
        onSecondaryTap: confirmRemove,
        behavior: HitTestBehavior.opaque,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
              backgroundColor: context.colors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(context.colors.primary),
            ),
            const SizedBox(height: 4),
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
