import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/history_item.dart';
import '../../../l10n/app_localizations.dart';
import '../../blocs/history/history_bloc.dart';
import '../../blocs/history/history_event.dart';
import '../../blocs/history/history_state.dart';
import '../../shared_widgets/tv_focusable.dart';

/// Pantalla de historial de reproducción.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<HistoryBloc>().add(const HistoryStarted());
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        return switch (state) {
          HistoryLoading() => const Center(child: CircularProgressIndicator()),
          HistoryFailure() => _EmptyView(message: l10n.historyLoadError),
          HistoryLoaded() => state.items.isEmpty
              ? _EmptyView(message: l10n.noHistory)
              : _HistoryList(items: state.items),
        };
      },
    );
  }
}

/// Lista de entradas del historial.
class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.items});

  final List<HistoryItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _HistoryTile(item: items[index], autofocus: index == 0);
      },
    );
  }
}

/// Fila de una entrada del historial.
class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item, this.autofocus = false});

  final HistoryItem item;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final IconData icon = switch (item.contentType.name) {
      'live' => Icons.live_tv,
      'vod' => Icons.movie,
      'series' => Icons.theaters,
      _ => Icons.tv,
    };

    final String timeAgo = _timeAgo(context, item.watchedAt);

    return TvFocusable(
      autofocus: autofocus,
      borderRadius: BorderRadius.circular(8),
      child: ListTile(
        leading: _Logo(logo: item.logo, icon: icon),
        title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(timeAgo),
      ),
    );
  }

  String _timeAgo(BuildContext context, DateTime watchedAt) {
    final Duration diff = DateTime.now().difference(watchedAt);
    final l10n = AppLocalizations.of(context)!;
    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inHours < 1) return l10n.minutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return l10n.hoursAgo(diff.inHours);
    if (diff.inDays < 7) return l10n.daysAgo(diff.inDays);
    return DateFormat.yMMMd().format(watchedAt);
  }
}

/// Logo del historial con fallback.
class _Logo extends StatelessWidget {
  const _Logo({required this.logo, required this.icon});

  final String? logo;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final String? url = logo;
    if (url == null || url.isEmpty) {
      return _fallback;
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 40,
        height: 40,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.contain,
          placeholder: (context, url) => _fallback,
          errorWidget: (context, url, error) => _fallback,
        ),
      ),
    );
  }

  Widget get _fallback => Container(
    width: 40,
    height: 40,
    color: AppColors.surfaceVariant,
    child: Icon(icon, color: AppColors.primary, size: 22),
  );
}

/// Vista vacía o de error.
class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.history, size: 56, color: AppColors.surfaceVariant),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
