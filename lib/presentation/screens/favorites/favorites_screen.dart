import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app.dart';
import '../../../core/media/playback_request.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/channel.dart';
import '../../../domain/entities/favorite_channel_group.dart';
import '../../../domain/entities/favorite_item.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/entities/series.dart';
import '../../../domain/repositories/iptv_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../blocs/favorites/favorites_bloc.dart';
import '../../blocs/favorites/favorites_event.dart';
import '../../blocs/favorites/favorites_state.dart';
import '../../shared_widgets/tv_focusable.dart';
import '../../shared_widgets/tv_marquee_text.dart';
import '../player/playback_scope.dart';

/// Pantalla de favoritos con lista de contenido guardado.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<FavoritesBloc>().add(const FavoritesStarted());
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.favorites)),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          return switch (state) {
            FavoritesLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            FavoritesFailure() => _EmptyView(message: l10n.favoritesLoadError),
            FavoritesLoaded() =>
              state.items.isEmpty && state.groups.isEmpty
                  ? _EmptyView(message: l10n.noFavorites)
                  : _FavoritesList(items: state.items, groups: state.groups),
          };
        },
      ),
    );
  }
}

/// Lista de elementos favoritos.
class _FavoritesList extends StatelessWidget {
  const _FavoritesList({required this.items, required this.groups});

  final List<FavoriteItem> items;
  final List<FavoriteChannelGroup> groups;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool hasGroups = groups.isNotEmpty;
    final bool hasItems = items.isNotEmpty;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: <Widget>[
        if (hasGroups) ...<Widget>[
          _SectionLabel(label: l10n.favoriteGroups),
          for (int i = 0; i < groups.length; i++)
            _FavoriteGroupTile(group: groups[i], autofocus: i == 0),
        ],
        if (hasItems) ...<Widget>[
          if (hasGroups) _SectionLabel(label: l10n.favorites),
          for (int i = 0; i < items.length; i++)
            _FavoriteTile(item: items[i], autofocus: !hasGroups && i == 0),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: context.colors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Grupo/categoría favorita: al pulsar se abre la lista de sus canales.
class _FavoriteGroupTile extends StatelessWidget {
  const _FavoriteGroupTile({required this.group, this.autofocus = false});

  final FavoriteChannelGroup group;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return TvFocusable(
      autofocus: autofocus,
      borderRadius: BorderRadius.circular(8),
      onPressed: () => context.push(Routes.favoriteGroup, extra: group),
      child: ListTile(
        leading: Icon(
          group.isRadio ? Icons.radio : Icons.folder_special,
          color: context.colors.primary,
        ),
        title: TvMarqueeText(text: group.name, maxLines: 1),
        subtitle: Text(l10n.favoriteGroups),
        trailing: IconButton(
          tooltip: l10n.removeGroupFromFavorites,
          icon: Icon(Icons.star, color: context.colors.primary),
          onPressed: () {
            context.read<FavoritesBloc>().add(FavoriteGroupToggled(group));
          },
        ),
        onTap: () => context.push(Routes.favoriteGroup, extra: group),
      ),
    );
  }
}

/// Fila de un elemento favorito.
class _FavoriteTile extends StatelessWidget {
  const _FavoriteTile({required this.item, this.autofocus = false});

  final FavoriteItem item;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final IconData icon = switch (item.contentType.name) {
      'live' => Icons.live_tv,
      'vod' => Icons.movie,
      'series' => Icons.theaters,
      _ => Icons.tv,
    };

    return TvFocusable(
      autofocus: autofocus,
      borderRadius: BorderRadius.circular(8),
      onPressed: () => _open(context),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _open(context),
        child: ListTile(
          leading: _Logo(logo: item.logo, icon: icon),
          title: TvMarqueeText(text: item.name, maxLines: 1),
          subtitle: Text(_typeLabel(context, item.contentType.name)),
          trailing: IconButton(
            icon: Icon(Icons.favorite, color: context.colors.primary),
            onPressed: () {
              context.read<FavoritesBloc>().add(
                FavoritesToggled(
                  item.contentId,
                  item.contentType.name,
                  item.name,
                  item.logo,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context) {
    switch (item.contentType.name) {
      case 'live':
        final IptvRepository repository = context.read<IptvRepository>();
        PlaybackScope.of(context).play(
          PlaybackRequest(
            title: item.name,
            urlBuilder: () => repository.buildStreamUrl(
              Channel(
                id: item.contentId,
                name: item.name,
                categoryId: 0,
                logo: item.logo,
              ),
            ),
            contentType: item.contentType.name,
            contentId: item.contentId,
          ),
        );
      case 'vod':
        // Abrir la ficha de la película para poder reproducirla.
        context.push(
          Routes.movieDetail,
          extra: Movie(
            id: item.contentId,
            name: item.name,
            categoryId: 0,
            streamIcon: item.logo,
          ),
        );
      case 'series':
        // Abrir la ficha de la serie para poder reproducir episodios.
        context.push(
          Routes.seriesDetail,
          extra: Series(id: item.contentId, name: item.name, cover: item.logo),
        );
    }
  }

  String _typeLabel(BuildContext context, String type) {
    final l10n = AppLocalizations.of(context)!;
    return switch (type) {
      'live' => l10n.liveTv,
      'vod' => l10n.movies,
      'series' => l10n.series,
      _ => type,
    };
  }
}

/// Logo del favorito con fallback.
class _Logo extends StatelessWidget {
  const _Logo({required this.logo, required this.icon});

  final String? logo;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final String? url = logo;
    if (url == null || url.isEmpty) {
      return _fallback(context);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 40,
        height: 40,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.contain,
          placeholder: (context, url) => _fallback(context),
          errorWidget: (context, url, error) => _fallback(context),
        ),
      ),
    );
  }

  Widget _fallback(BuildContext context) => Container(
    width: 40,
    height: 40,
    color: context.colors.surfaceVariant,
    child: Icon(icon, color: context.colors.primary, size: 22),
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
          Icon(
            Icons.favorite_border,
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
