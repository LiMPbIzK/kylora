import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/catchup.dart';
import '../../../domain/entities/epg.dart';
import '../../../l10n/app_localizations.dart';
import 'tv_focusable.dart';

/// Lista de programación EPG reutilizable.
///
/// Se posiciona en el programa actual (o en el siguiente) y permite navegar
/// con el D-Pad por toda la guía; al enfocar una fila se hace scroll hasta ella.
/// Las filas con catch-up disponible muestran el icono de reproducción.
class ProgramGuideList extends StatefulWidget {
  const ProgramGuideList({
    super.key,
    required this.entries,
    required this.hasArchive,
    this.archiveDurationDays,
    this.onPlay,
    this.compact = false,
  });

  final List<EpgEntry> entries;
  final bool hasArchive;
  final int? archiveDurationDays;
  final ValueChanged<EpgEntry>? onPlay;

  /// Variante compacta para la guía embebida del reproductor.
  final bool compact;

  @override
  State<ProgramGuideList> createState() => _ProgramGuideListState();
}

class _ProgramGuideListState extends State<ProgramGuideList> {
  final ScrollController _scrollController = ScrollController();
  GlobalKey _currentKey = GlobalKey();
  int _currentIndex = -1;

  @override
  void initState() {
    super.initState();
    _updateCurrent(force: true);
  }

  @override
  void didUpdateWidget(covariant ProgramGuideList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entries != widget.entries) {
      _updateCurrent(force: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateCurrent({bool force = false}) {
    final int next = _findCurrentIndex(widget.entries, DateTime.now());
    if (force || next != _currentIndex) {
      _currentIndex = next;
      _currentKey = GlobalKey();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final BuildContext? context = _currentKey.currentContext;
      if (context == null) return;
      Scrollable.ensureVisible(
        context,
        alignment: 0.25,
        duration: Duration.zero,
      );
    });
  }

  int _findCurrentIndex(List<EpgEntry> entries, DateTime now) {
    if (entries.isEmpty) return -1;
    final int onAir = entries.indexWhere(
      (EpgEntry entry) => entry.isOnAir(now),
    );
    if (onAir >= 0) return onAir;
    final int next = entries.indexWhere(
      (EpgEntry entry) => entry.start.isAfter(now),
    );
    return next >= 0 ? next : entries.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: <Widget>[
          for (int index = 0; index < widget.entries.length; index++)
            _buildTile(index, now),
        ],
      ),
    );
  }

  Widget _buildTile(int index, DateTime now) {
    final EpgEntry entry = widget.entries[index];
    final bool isOnAir = entry.isOnAir(now);
    final bool available = isCatchupAvailable(
      hasArchive: widget.hasArchive,
      archiveDurationDays: widget.archiveDurationDays,
      program: entry,
      now: now,
    );
    final VoidCallback? onPlay = available && widget.onPlay != null
        ? () => widget.onPlay!(entry)
        : null;

    return _GuideProgramTile(
      key: index == _currentIndex ? _currentKey : null,
      entry: entry,
      isOnAir: isOnAir,
      onPlay: onPlay,
      autofocus: index == _currentIndex,
      compact: widget.compact,
    );
  }
}

class _GuideProgramTile extends StatelessWidget {
  const _GuideProgramTile({
    super.key,
    required this.entry,
    required this.isOnAir,
    required this.onPlay,
    required this.autofocus,
    required this.compact,
  });

  final EpgEntry entry;
  final bool isOnAir;
  final VoidCallback? onPlay;
  final bool autofocus;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final String time =
        '${_two(entry.start.hour)}:${_two(entry.start.minute)}'
        ' - ${_two(entry.end.hour)}:${_two(entry.end.minute)}';
    final AppColors colors = context.colors;

    final Widget content = Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: EdgeInsets.all(compact ? 10 : 12),
      decoration: BoxDecoration(
        color: isOnAir ? colors.primaryContainer : colors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: compact ? 78 : 90,
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
                    fontWeight: isOnAir ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (entry.description?.isNotEmpty == true) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    entry.description!,
                    maxLines: compact ? 2 : 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: compact ? 12 : 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onPlay != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(
                Icons.play_circle_outline,
                color: colors.primary,
                semanticLabel: AppLocalizations.of(context)!.playFromStart,
              ),
            ),
        ],
      ),
    );

    return TvFocusable(
      autofocus: autofocus,
      onPressed: onPlay,
      borderRadius: BorderRadius.circular(8),
      onFocusChanged: (bool focused) {
        if (focused) {
          Scrollable.ensureVisible(
            context,
            alignment: 0.25,
            duration: const Duration(milliseconds: 180),
          );
        }
      },
      child: content,
    );
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}
