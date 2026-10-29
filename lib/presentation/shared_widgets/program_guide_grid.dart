import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/reminders/epg_reminder_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/catchup.dart';
import '../../../domain/entities/epg.dart';
import '../../../l10n/app_localizations.dart';
import 'tv_focusable.dart';

/// Parrilla temporal diaria para la EPG de un canal.
class ProgramGuideGrid extends StatefulWidget {
  const ProgramGuideGrid({
    super.key,
    required this.entries,
    required this.streamId,
    required this.channelName,
    required this.hasArchive,
    this.archiveDurationDays,
    this.logo,
    this.onPlay,
  });

  final List<EpgEntry> entries;
  final int streamId;
  final String channelName;
  final bool hasArchive;
  final int? archiveDurationDays;
  final String? logo;
  final ValueChanged<EpgEntry>? onPlay;

  @override
  State<ProgramGuideGrid> createState() => _ProgramGuideGridState();
}

class _ProgramGuideGridState extends State<ProgramGuideGrid> {
  static const double _pixelsPerMinute = 2.0;
  static const double _dayWidth = 24 * 60 * _pixelsPerMinute;
  static const double _rulerHeight = 30;
  static const double _blockTop = 38;
  static const double _blockHeight = 104;

  final ScrollController _scrollController = ScrollController();
  late DateTime _day;
  double _viewportWidth = 0;

  @override
  void initState() {
    super.initState();
    _day = _initialDay();
    _scheduleScrollToCurrent();
  }

  @override
  void didUpdateWidget(covariant ProgramGuideGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entries != widget.entries) {
      _scheduleScrollToCurrent();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  DateTime _initialDay() {
    final DateTime now = DateTime.now();
    final Iterable<EpgEntry> currentEntries = widget.entries.where(
      (EpgEntry entry) => entry.isOnAir(now),
    );
    final EpgEntry? current = currentEntries.isEmpty
        ? null
        : currentEntries.first;
    final DateTime source =
        current?.start ??
        (widget.entries.isEmpty ? now : widget.entries.first.start);
    return DateTime(source.year, source.month, source.day);
  }

  List<EpgEntry> _entriesForDay() {
    final DateTime start = _day;
    final DateTime end = _day.add(const Duration(days: 1));
    return widget.entries
        .where(
          (EpgEntry entry) =>
              entry.start.isBefore(end) && entry.end.isAfter(start),
        )
        .toList();
  }

  void _scheduleScrollToCurrent() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final DateTime now = DateTime.now();
      final int minutes = _isToday ? now.hour * 60 + now.minute : 8 * 60;
      final double target =
          minutes * _pixelsPerMinute -
          (_viewportWidth > 0 ? _viewportWidth / 2 : 0);
      _scrollController.jumpTo(
        target.clamp(0.0, _scrollController.position.maxScrollExtent),
      );
    });
  }

  bool get _isToday {
    final DateTime now = DateTime.now();
    return now.year == _day.year &&
        now.month == _day.month &&
        now.day == _day.day;
  }

  void _moveDay(int delta) {
    setState(() {
      _day = _day.add(Duration(days: delta));
    });
    _scheduleScrollToCurrent();
  }

  void _goToday() {
    final DateTime now = DateTime.now();
    setState(() {
      _day = DateTime(now.year, now.month, now.day);
    });
    _scheduleScrollToCurrent();
  }

  EpgReminder _reminderFor(EpgEntry entry) => EpgReminder(
    streamId: widget.streamId,
    channelName: widget.channelName,
    title: entry.title,
    start: entry.start,
    end: entry.end,
    logo: widget.logo,
  );

  void _onProgramPressed(EpgEntry entry) {
    final bool available = isCatchupAvailable(
      hasArchive: widget.hasArchive,
      archiveDurationDays: widget.archiveDurationDays,
      program: entry,
    );
    if (available && widget.onPlay != null) {
      widget.onPlay!(entry);
      return;
    }
    if (entry.start.isAfter(DateTime.now())) {
      final EpgReminder reminder = _reminderFor(entry);
      EpgReminderService.instance.toggle(reminder);
      final AppLocalizations l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            EpgReminderService.instance.isSet(reminder)
                ? l10n.reminderSet
                : l10n.reminderRemoved,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String locale = Localizations.localeOf(context).toLanguageTag();
    final List<EpgEntry> entries = _entriesForDay();
    final DateTime now = DateTime.now();

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
          child: Row(
            children: <Widget>[
              IconButton(
                tooltip: l10n.previous,
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _moveDay(-1),
              ),
              Expanded(
                child: Text(
                  DateFormat.yMMMMd(locale).format(_day),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(onPressed: _goToday, child: Text(l10n.today)),
              IconButton(
                tooltip: l10n.next,
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _moveDay(1),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              _viewportWidth = constraints.maxWidth;
              return ListenableBuilder(
                listenable: EpgReminderService.instance,
                builder: (context, child) {
                  return SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: _dayWidth,
                      height: constraints.maxHeight,
                      child: Stack(
                        children: <Widget>[
                          ..._buildRuler(context),
                          ..._buildPrograms(entries, now),
                          if (_isToday)
                            Positioned(
                              left:
                                  (now.hour * 60 + now.minute) *
                                  _pixelsPerMinute,
                              top: _rulerHeight,
                              bottom: 0,
                              child: IgnorePointer(
                                child: Container(
                                  width: 2,
                                  color: context.colors.error,
                                ),
                              ),
                            ),
                          if (entries.isEmpty)
                            Center(child: Text(l10n.epgNoProgram)),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRuler(BuildContext context) {
    final List<Widget> widgets = <Widget>[];
    for (int hour = 0; hour <= 24; hour++) {
      final double left = hour * 60 * _pixelsPerMinute;
      widgets.add(
        Positioned(
          left: left,
          top: 0,
          child: SizedBox(
            width: 52,
            child: Text(
              '${hour.toString().padLeft(2, '0')}:00',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ),
      );
      widgets.add(
        Positioned(
          left: left,
          top: _rulerHeight - 5,
          bottom: 0,
          child: Container(width: 1, color: context.colors.surfaceVariant),
        ),
      );
    }
    return widgets;
  }

  List<Widget> _buildPrograms(List<EpgEntry> entries, DateTime now) {
    final List<Widget> widgets = <Widget>[];
    final DateTime dayEnd = _day.add(const Duration(days: 1));
    for (final EpgEntry entry in entries) {
      final DateTime start = entry.start.isBefore(_day) ? _day : entry.start;
      final DateTime end = entry.end.isAfter(dayEnd) ? dayEnd : entry.end;
      final double left = start.difference(_day).inMinutes * _pixelsPerMinute;
      final double width = (end.difference(start).inMinutes * _pixelsPerMinute)
          .clamp(44.0, _dayWidth);
      final bool isOnAir = entry.isOnAir(now);
      final bool canPlay = isCatchupAvailable(
        hasArchive: widget.hasArchive,
        archiveDurationDays: widget.archiveDurationDays,
        program: entry,
      );
      final bool canRemind = entry.start.isAfter(now);
      final bool reminderSet =
          canRemind && EpgReminderService.instance.isSet(_reminderFor(entry));
      final AppColors colors = context.colors;

      widgets.add(
        Positioned(
          left: left,
          top: _blockTop,
          width: width,
          height: _blockHeight,
          child: Builder(
            builder: (BuildContext tileContext) => TvFocusable(
              autofocus: isOnAir,
              borderRadius: BorderRadius.circular(8),
              onFocusChanged: (bool focused) {
                if (focused) {
                  Scrollable.ensureVisible(
                    tileContext,
                    alignment: 0.25,
                    duration: const Duration(milliseconds: 180),
                  );
                }
              },
              onPressed: (canPlay && widget.onPlay != null) || canRemind
                  ? () => _onProgramPressed(entry)
                  : null,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isOnAir
                      ? colors.primaryContainer
                      : colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isOnAir ? colors.primary : colors.surfaceVariant,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            '${_two(entry.start.hour)}:${_two(entry.start.minute)}',
                            style: TextStyle(
                              color: isOnAir
                                  ? colors.primary
                                  : colors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (canPlay)
                          Icon(
                            Icons.play_circle_outline,
                            size: 18,
                            color: colors.primary,
                          )
                        else if (canRemind)
                          Icon(
                            reminderSet
                                ? Icons.notifications
                                : Icons.notifications_none,
                            size: 18,
                            color: colors.primary,
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Expanded(
                      child: Text(
                        entry.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: isOnAir
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
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
    return widgets;
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}
