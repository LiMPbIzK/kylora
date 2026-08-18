import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/media/playback_request.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/channel.dart';
import '../../../domain/repositories/iptv_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../blocs/live/live_bloc.dart';
import '../../blocs/live/live_event.dart';
import '../../blocs/live/live_state.dart';
import '../player/playback_scope.dart';

/// Catálogo de canales en directo con categorías y logos.
class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  @override
  void initState() {
    super.initState();
    // La carga se dispara al montar la pantalla para no depender de la navegación.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<LiveBloc>().add(const LiveStarted());
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return BlocBuilder<LiveBloc, LiveState>(
      builder: (context, state) {
        return switch (state) {
          LiveLoading() => const Center(child: CircularProgressIndicator()),
          LiveFailure() => _ErrorView(message: l10n.liveLoadError),
          LiveLoaded() => _LiveContent(state: state),
        };
      },
    );
  }
}

/// Contenido del catálogo: chips de categorías y lista de canales.
class _LiveContent extends StatelessWidget {
  const _LiveContent({required this.state});

  final LiveLoaded state;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Column(
      children: <Widget>[
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
              ? Center(child: Text(l10n.noChannels))
              : ListView.builder(
                  itemCount: state.channels.length,
                  itemBuilder: (context, index) {
                    return _ChannelTile(channel: state.channels[index]);
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

/// Fila de canal con logo en red.
class _ChannelTile extends StatelessWidget {
  const _ChannelTile({required this.channel});

  final Channel channel;

  @override
  Widget build(BuildContext context) {
    final String? number = channel.number != null ? '${channel.number}' : null;

    return ListTile(
      leading: _ChannelLogo(logo: channel.logo),
      title: Text(channel.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: number != null ? Text('CH $number') : null,
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.surfaceVariant,
      ),
      onTap: () {
        final IptvRepository repository = context.read<IptvRepository>();
        PlaybackScope.of(context).play(
          PlaybackRequest(
            title: channel.name,
            urlBuilder: () => repository.buildStreamUrl(channel),
          ),
        );
      },
    );
  }
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
