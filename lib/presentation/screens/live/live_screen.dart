import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app.dart';
import '../../../core/media/playback_request.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/channel.dart';
import '../../../domain/entities/epg.dart';
import '../../../domain/repositories/iptv_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../blocs/epg/epg_bloc.dart';
import '../../blocs/epg/epg_event.dart';
import '../../blocs/epg/epg_state.dart';
import '../../blocs/live/live_bloc.dart';
import '../../blocs/live/live_event.dart';
import '../../blocs/live/live_state.dart';
import '../../shared_widgets/tv_focusable.dart';
import '../player/playback_scope.dart';

/// Catálogo de canales en directo con categorías y logos.
class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // La carga se dispara al montar la pantalla para no depender de la navegación.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<LiveBloc>().add(const LiveStarted());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return BlocBuilder<LiveBloc, LiveState>(
      builder: (context, state) {
        return switch (state) {
          LiveLoading() => const Center(child: CircularProgressIndicator()),
          LiveFailure() => _ErrorView(message: l10n.liveLoadError),
          LiveLoaded() => _LiveContent(state: state, controller: _searchController),
        };
      },
    );
  }
}

/// Contenido del catálogo: buscador, chips de categorías y lista de canales.
class _LiveContent extends StatelessWidget {
  const _LiveContent({required this.state, required this.controller});

  final LiveLoaded state;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: TextField(
            controller: controller,
            onChanged: (String value) =>
                context.read<LiveBloc>().add(LiveSearchChanged(value)),
            decoration: InputDecoration(
              hintText: l10n.searchPlaceholder,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: state.isSearching
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.clear();
                        context.read<LiveBloc>().add(const LiveSearchChanged(''));
                      },
                    )
                  : null,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.surfaceVariant),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            children: <Widget>[
              _CategoryChip(
                label: l10n.allCategories,
                selected: state.isAllSelected,
                onTap: () => context.read<LiveBloc>().add(
                  const LiveCategorySelected(null),
                ),
              ),
              for (final Category category in state.categories)
                _CategoryChip(
                  label: category.name,
                  selected: state.selectedCategoryId == category.id,
                  onTap: () => context.read<LiveBloc>().add(
                    LiveCategorySelected(category.id),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: state.channels.isEmpty
              ? Center(
                  child: Text(
                    state.isSearching ? l10n.searchNoResults : l10n.noChannels,
                  ),
                )
              : ListView.builder(
                  itemCount: state.channels.length,
                  itemBuilder: (context, index) {
                    return _ChannelTile(
                      channel: state.channels[index],
                      autofocus: index == 0,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Chip de categoría seleccionable.
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        labelStyle: TextStyle(
          color: selected ? AppColors.onPrimary : AppColors.onSurface,
        ),
        side: BorderSide(color: AppColors.surfaceVariant),
      ),
    );
  }
}

/// Fila de canal con logo, programa ahora/siguiente y acceso a la guía.
class _ChannelTile extends StatefulWidget {
  const _ChannelTile({required this.channel, this.autofocus = false});

  final Channel channel;
  final bool autofocus;

  @override
  State<_ChannelTile> createState() => _ChannelTileState();
}

class _ChannelTileState extends State<_ChannelTile> {
  @override
  void initState() {
    super.initState();
    // Carga el EPG corto (ahora/siguiente) del canal si aún no está en caché.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<EpgBloc>().add(EpgNowNextRequested(widget.channel.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? number =
        widget.channel.number != null ? '${widget.channel.number}' : null;

    return TvFocusable(
      autofocus: widget.autofocus,
      borderRadius: BorderRadius.circular(8),
      onPressed: _play,
      child: ListTile(
        leading: _ChannelLogo(logo: widget.channel.logo),
        title: Text(
          widget.channel.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (number != null)
              Text('CH $number', style: const TextStyle(fontSize: 12)),
            _EpgLine(streamId: widget.channel.id),
          ],
        ),
        isThreeLine: true,
        trailing: IconButton(
          tooltip: context.l10n.epgGuide,
          icon: const Icon(
            Icons.calendar_view_day,
            color: AppColors.primary,
          ),
          onPressed: () => context.push(
            Routes.programGuide,
            extra: widget.channel,
          ),
        ),
        onTap: _play,
      ),
    );
  }

  void _play() {
    final IptvRepository repository = context.read<IptvRepository>();
    PlaybackScope.of(context).play(
      PlaybackRequest(
        title: widget.channel.name,
        urlBuilder: () => repository.buildStreamUrl(widget.channel),
        contentType: 'live',
        contentId: widget.channel.id,
      ),
    );
  }
}

/// Línea que muestra el programa actual y el siguiente de un canal.
class _EpgLine extends StatelessWidget {
  const _EpgLine({required this.streamId});

  final int streamId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EpgBloc, EpgState>(
      buildWhen: (previous, current) =>
          current is EpgNowNextLoaded &&
          current.streamId == streamId,
      builder: (context, state) {
        if (state is! EpgNowNextLoaded || state.streamId != streamId) {
          return const SizedBox.shrink();
        }
        final List<String> lines = <String>[];
        if (state.now != null) {
          lines.add(_nowLabel(context.l10n, state.now!));
        }
        if (state.next != null) {
          lines.add(_nextLabel(context.l10n, state.next!));
        }
        if (lines.isEmpty) {
          return Text(
            context.l10n.epgNoProgram,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (final String line in lines)
              Text(
                line,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
          ],
        );
      },
    );
  }

  String _nowLabel(AppLocalizations l10n, EpgEntry entry) {
    final String time = _hour(entry.start);
    return '${l10n.nowEpg} $time · ${entry.title}';
  }

  String _nextLabel(AppLocalizations l10n, EpgEntry entry) {
    final String time = _hour(entry.start);
    return '${l10n.nextEpg} $time · ${entry.title}';
  }

  String _hour(DateTime time) {
    final String hh = time.hour.toString().padLeft(2, '0');
    final String mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}

extension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

/// Logo del canal con placeholder y manejo de errores de carga.
class _ChannelLogo extends StatelessWidget {
  const _ChannelLogo({required this.logo});

  final String? logo;

  @override
  Widget build(BuildContext context) {
    final String? url = logo;
    if (url == null || url.isEmpty) {
      return _fallbackLogo;
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 40,
        height: 40,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.contain,
          placeholder: (context, url) => _fallbackLogo,
          errorWidget: (context, url, error) => _fallbackLogo,
        ),
      ),
    );
  }

  Widget get _fallbackLogo => Container(
    width: 40,
    height: 40,
    color: AppColors.surfaceVariant,
    child: const Icon(Icons.tv, color: AppColors.primary, size: 22),
  );
}

/// Vista de error de carga del catálogo.
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.error_outline, size: 56, color: AppColors.error),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: () => context.read<LiveBloc>().add(const LiveStarted()),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}
