import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/media/playback_request.dart';
import '../../../core/reminders/epg_reminder_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/catchup.dart';
import '../../../domain/entities/channel.dart';
import '../../../domain/entities/epg.dart';
import '../../../domain/repositories/iptv_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared_widgets/tv_focusable.dart';
import '../player/playback_scope.dart';

/// Datos para abrir la guía multi-canal desde una sección.
class MultiChannelGuideData {
  const MultiChannelGuideData({
    required this.channels,
    required this.title,
    required this.radio,
  });

  final List<Channel> channels;
  final String title;
  final bool radio;
}

/// Guía temporal con varias filas de canales.
class MultiChannelGuideScreen extends StatefulWidget {
  const MultiChannelGuideScreen({super.key, required this.data});

  final MultiChannelGuideData data;

  @override
  State<MultiChannelGuideScreen> createState() =>
      _MultiChannelGuideScreenState();
}

class _MultiChannelGuideScreenState extends State<MultiChannelGuideScreen> {
  static const double _channelWidth = 150;
  static const double _rowHeight = 64;
  static const double _rulerHeight = 30;
  static const double _pixelsPerMinute = 2.0;
  static const double _dayWidth = 24 * 60 * _pixelsPerMinute;
  static const int _maxChannels = 30;

  late DateTime _day;
  late Future<Map<int, List<EpgEntry>>> _future;
  late List<Channel> _channels;
  final ScrollController _horizontalController = ScrollController();
  bool _centeredOnNow = false;

  @override
  void initState() {
    super.initState();
    _day = DateTime.now();
    _channels = widget.data.channels.take(_maxChannels).toList();
    _load();
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  void _load() {
    _future = context.read<IptvRepository>().fetchMultiChannelEpg(_channels);
  }

  List<EpgEntry> _dayEntries(Map<int, List<EpgEntry>> all, int streamId) {
    final DateTime start = DateTime(_day.year, _day.month, _day.day);
    final DateTime end = start.add(const Duration(days: 1));
    return (all[streamId] ?? <EpgEntry>[])
        .where(
          (EpgEntry entry) =>
              entry.start.isBefore(end) && entry.end.isAfter(start),
        )
        .toList();
  }

  Future<void> _play(Channel channel, EpgEntry entry) async {
    final IptvRepository repository = context.read<IptvRepository>();
    final String? url = await repository.buildCatchupUrl(
      streamId: channel.id,
      hasArchive: channel.hasArchive,
      archiveDurationDays: channel.archiveDurationDays,
      program: entry,
    );
    if (!mounted) return;
    if (url == null) return;
    PlaybackScope.of(context).play(
      PlaybackRequest(
        title: '${channel.name} · ${entry.title}',
        urlBuilder: () async => url,
        contentType: 'live',
        contentId: channel.id,
        hasArchive: channel.hasArchive,
        archiveDurationDays: channel.archiveDurationDays,
        channelTitle: channel.name,
        logo: channel.logo,
        isRadio: widget.data.radio,
      ),
    );
  }

  void _onProgramPressed(Channel channel, EpgEntry entry) {
    final bool canPlay = isCatchupAvailable(
      hasArchive: channel.hasArchive,
      archiveDurationDays: channel.archiveDurationDays,
      program: entry,
    );
    if (canPlay) {
      _play(channel, entry);
      return;
    }
    if (entry.start.isAfter(DateTime.now())) {
      final EpgReminder reminder = EpgReminder(
        streamId: channel.id,
        channelName: channel.name,
        title: entry.title,
        start: entry.start,
        end: entry.end,
        logo: channel.logo,
      );
      final bool wasSet = EpgReminderService.instance.isSet(reminder);
      EpgReminderService.instance.toggle(reminder);
      final AppLocalizations l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(wasSet ? l10n.reminderRemoved : l10n.reminderSet),
        ),
      );
    }
  }

  void _moveDay(int delta) {
    setState(() {
      _day = _day.add(Duration(days: delta));
      _centeredOnNow = false;
    });
  }

  void _centerOnNow() {
    if (_centeredOnNow || !_horizontalController.hasClients) return;
    _centeredOnNow = true;
    final DateTime now = DateTime.now();
    final double target = (now.hour * 60 + now.minute) * _pixelsPerMinute - 120;
    _horizontalController.jumpTo(
      target.clamp(0.0, _horizontalController.position.maxScrollExtent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String locale = Localizations.localeOf(context).toLanguageTag();
    final DateTime now = DateTime.now();
    final bool isToday =
        now.year == _day.year && now.month == _day.month && now.day == _day.day;

    return Scaffold(
      appBar: AppBar(title: Text(widget.data.title)),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                TextButton(
                  onPressed: () => setState(() {
                    _day = DateTime.now();
                  }),
                  child: Text(l10n.today),
                ),
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
            child: FutureBuilder<Map<int, List<EpgEntry>>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text(l10n.liveLoadError));
                }
                final Map<int, List<EpgEntry>> all =
                    snapshot.data ?? <int, List<EpgEntry>>{};
                final bool hasEntries = _channels.any(
                  (Channel channel) => _dayEntries(all, channel.id).isNotEmpty,
                );
                if (!hasEntries) {
                  return Center(child: Text(l10n.epgNoProgram));
                }
                if (isToday) {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _centerOnNow(),
                  );
                }
                return SingleChildScrollView(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: _channelWidth,
                        child: Column(
                          children: <Widget>[
                            const SizedBox(height: _rulerHeight),
                            for (final Channel channel in _channels)
                              SizedBox(
                                height: _rowHeight,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      channel.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _horizontalController,
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: _dayWidth,
                            child: Stack(
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    _buildRuler(context),
                                    for (final Channel channel in _channels)
                                      SizedBox(
                                        height: _rowHeight,
                                        child: _buildChannelRow(
                                          context,
                                          channel,
                                          all,
                                          now,
                                        ),
                                      ),
                                  ],
                                ),
                                if (isToday)
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
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuler(BuildContext context) {
    return SizedBox(
      height: _rulerHeight,
      child: Stack(
        children: <Widget>[
          for (int hour = 0; hour <= 24; hour++)
            Positioned(
              left: hour * 60 * _pixelsPerMinute,
              top: 0,
              child: Text(
                '${hour.toString().padLeft(2, '0')}:00',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChannelRow(
    BuildContext context,
    Channel channel,
    Map<int, List<EpgEntry>> all,
    DateTime now,
  ) {
    final List<EpgEntry> entries = _dayEntries(all, channel.id);
    final DateTime start = DateTime(_day.year, _day.month, _day.day);
    final DateTime end = start.add(const Duration(days: 1));
    return Stack(
      children: <Widget>[
        for (final EpgEntry entry in entries)
          Positioned(
            left:
                (entry.start.isBefore(start) ? start : entry.start)
                    .difference(start)
                    .inMinutes *
                _pixelsPerMinute,
            top: 3,
            height: _rowHeight - 6,
            width:
                ((entry.end.isAfter(end) ? end : entry.end)
                            .difference(
                              entry.start.isBefore(start) ? start : entry.start,
                            )
                            .inMinutes *
                        _pixelsPerMinute)
                    .clamp(30.0, _dayWidth),
            child: Builder(
              builder: (BuildContext tileContext) => TvFocusable(
                borderRadius: BorderRadius.circular(6),
                onFocusChanged: (bool focused) {
                  if (focused) {
                    Scrollable.ensureVisible(
                      tileContext,
                      alignment: 0.25,
                      duration: const Duration(milliseconds: 180),
                    );
                  }
                },
                onPressed: () => _onProgramPressed(channel, entry),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: entry.isOnAir(now)
                        ? context.colors.primaryContainer
                        : context.colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    entry.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: entry.isOnAir(now)
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
