import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/media/playback_request.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/channel.dart';
import '../../../domain/entities/epg.dart';
import '../../../domain/repositories/iptv_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../blocs/epg/epg_bloc.dart';
import '../../blocs/epg/epg_event.dart';
import '../../blocs/epg/epg_state.dart';
import '../../shared_widgets/program_guide_list.dart';
import '../player/playback_scope.dart';

/// Vista de programación EPG completa de un canal en directo.
class ProgramGuideScreen extends StatefulWidget {
  const ProgramGuideScreen({super.key, required this.channel});

  final Channel channel;

  @override
  State<ProgramGuideScreen> createState() => _ProgramGuideScreenState();
}

class _ProgramGuideScreenState extends State<ProgramGuideScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<EpgBloc>().add(
          EpgGuideRequested(widget.channel.id, widget.channel.name),
        );
      }
    });
  }

  /// Entra al canal desde la propia guía, sin necesidad de volver al catálogo.
  void _playChannel() {
    final IptvRepository repository = context.read<IptvRepository>();
    PlaybackScope.of(context).play(
      PlaybackRequest(
        title: widget.channel.name,
        urlBuilder: () => repository.buildStreamUrl(widget.channel),
        contentType: 'live',
        contentId: widget.channel.id,
        hasArchive: widget.channel.hasArchive,
        archiveDurationDays: widget.channel.archiveDurationDays,
        channelTitle: widget.channel.name,
      ),
    );
  }

  Future<void> _playCatchup(EpgEntry entry) async {
    final IptvRepository repository = context.read<IptvRepository>();
    final String? url = await repository.buildCatchupUrl(
      streamId: widget.channel.id,
      hasArchive: widget.channel.hasArchive,
      archiveDurationDays: widget.channel.archiveDurationDays,
      program: entry,
    );
    if (!mounted) return;
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.catchupUnavailable),
        ),
      );
      return;
    }
    PlaybackScope.of(context).play(
      PlaybackRequest(
        title: '${widget.channel.name} · ${entry.title}',
        urlBuilder: () async => url,
        contentType: 'live',
        contentId: widget.channel.id,
        hasArchive: widget.channel.hasArchive,
        archiveDurationDays: widget.channel.archiveDurationDays,
        channelTitle: widget.channel.name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.channel.name),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.play,
            icon: const Icon(Icons.play_arrow),
            onPressed: _playChannel,
          ),
        ],
      ),
      body: BlocBuilder<EpgBloc, EpgState>(
        builder: (context, state) {
          return switch (state) {
            EpgIdle() ||
            EpgLoading() => const Center(child: CircularProgressIndicator()),
            EpgGuideLoaded() => ProgramGuideList(
              entries: state.entries,
              hasArchive: widget.channel.hasArchive,
              archiveDurationDays: widget.channel.archiveDurationDays,
              onPlay: _playCatchup,
            ),
            EpgEmpty() => _EmptyView(message: l10n.epgNoProgram),
            EpgNowNextLoaded() ||
            EpgFailure() => _EmptyView(message: l10n.epgLoadError),
          };
        },
      ),
    );
  }
}

/// Vista vacía o error.
class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.event_note,
            size: 56,
            color: context.colors.surfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
