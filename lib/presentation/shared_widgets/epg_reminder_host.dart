import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/media/playback_request.dart';
import '../../../core/reminders/epg_reminder_service.dart';
import '../../../domain/entities/channel.dart';
import '../../../domain/repositories/iptv_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../screens/player/playback_scope.dart';

/// Muestra un aviso cuando vence un recordatorio EPG.
class EpgReminderHost extends StatefulWidget {
  const EpgReminderHost({
    super.key,
    required this.navigatorKey,
    required this.child,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  State<EpgReminderHost> createState() => _EpgReminderHostState();
}

class _EpgReminderHostState extends State<EpgReminderHost> {
  bool _showing = false;

  @override
  void initState() {
    super.initState();
    EpgReminderService.instance.addListener(_onReminder);
    WidgetsBinding.instance.addPostFrameCallback((_) => _showNext());
  }

  @override
  void dispose() {
    EpgReminderService.instance.removeListener(_onReminder);
    super.dispose();
  }

  void _onReminder() => _showNext();

  Future<void> _showNext() async {
    if (_showing || !mounted) return;
    final BuildContext? context = widget.navigatorKey.currentContext;
    if (context == null) return;
    final EpgReminder? reminder = EpgReminderService.instance.takeDue();
    if (reminder == null) return;

    _showing = true;
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.reminderDueTitle),
          content: Text('${reminder.channelName}\n${reminder.title}'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.close),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _play(reminder);
              },
              child: Text(l10n.watchNow),
            ),
          ],
        );
      },
    );
    _showing = false;
    if (mounted) _showNext();
  }

  Future<void> _play(EpgReminder reminder) async {
    final BuildContext? context = widget.navigatorKey.currentContext;
    if (context == null || !context.mounted) return;
    final IptvRepository repository = context.read<IptvRepository>();
    final Channel channel = Channel(
      id: reminder.streamId,
      name: reminder.channelName,
      categoryId: 0,
      logo: reminder.logo,
    );
    final String url = await repository.buildStreamUrl(channel);
    if (!context.mounted) return;
    PlaybackScope.of(context).play(
      PlaybackRequest(
        title: reminder.channelName,
        urlBuilder: () async => url,
        contentType: 'live',
        contentId: reminder.streamId,
        logo: reminder.logo,
        channelTitle: reminder.channelName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
