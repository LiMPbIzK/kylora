import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/channel.dart';
import '../../../domain/entities/epg.dart';
import '../../../l10n/app_localizations.dart';
import '../../blocs/epg/epg_bloc.dart';
import '../../blocs/epg/epg_event.dart';
import '../../blocs/epg/epg_state.dart';

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

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(widget.channel.name)),
      body: BlocBuilder<EpgBloc, EpgState>(
        builder: (context, state) {
          return switch (state) {
            EpgIdle() || EpgLoading() =>
              const Center(child: CircularProgressIndicator()),
            EpgGuideLoaded() => _GuideList(entries: state.entries),
            EpgEmpty() => _EmptyView(message: l10n.epgNoProgram),
            EpgNowNextLoaded() || EpgFailure() => _EmptyView(
              message: l10n.epgLoadError,
            ),
          };
        },
      ),
    );
  }
}

/// Lista de programas del canal con el programa actual resaltado.
class _GuideList extends StatelessWidget {
  const _GuideList({required this.entries});

  final List<EpgEntry> entries;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final EpgEntry entry = entries[index];
        return _ProgramTile(
          entry: entry,
          isOnAir: entry.isOnAir(DateTime.now()),
        );
      },
    );
  }
}

/// Fila de un programa con su franja horaria.
class _ProgramTile extends StatelessWidget {
  const _ProgramTile({required this.entry, required this.isOnAir});

  final EpgEntry entry;
  final bool isOnAir;

  @override
  Widget build(BuildContext context) {
    final String time = _formatRange(entry.start, entry.end);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOnAir ? AppColors.primaryContainer : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 90,
            child: Text(
              time,
              style: TextStyle(
                color: isOnAir ? AppColors.primary : AppColors.onSurface,
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
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatRange(DateTime start, DateTime end) {
    final DateFormat timeFormat = DateFormat('HH:mm');
    return '${timeFormat.format(start)} - ${timeFormat.format(end)}';
  }
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
          const Icon(Icons.event_note, size: 56, color: AppColors.surfaceVariant),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
