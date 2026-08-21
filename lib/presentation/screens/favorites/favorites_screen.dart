import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/media/playback_request.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/channel.dart';
import '../../../domain/entities/favorite_item.dart';
import '../../../domain/repositories/iptv_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../blocs/favorites/favorites_bloc.dart';
import '../../blocs/favorites/favorites_event.dart';
import '../../blocs/favorites/favorites_state.dart';
import '../../shared_widgets/tv_focusable.dart';
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

    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        return switch (state) {
          FavoritesLoading() => const Center(child: CircularProgressIndicator()),
          FavoritesFailure() => _EmptyView(message: l10n.favoritesLoadError),
          FavoritesLoaded() => state.items.isEmpty
              ? _EmptyView(message: l10n.noFavorites)
              : _FavoritesList(items: state.items),
        };
      },
    );
  }
}

/// Lista de elementos favoritos.
class _FavoritesList extends StatelessWidget {
  const _FavoritesList({required this.items});

  final List<FavoriteItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _FavoriteTile(item: items[index], autofocus: index == 0);
      },
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
      child: ListTile(
        leading: _Logo(logo: item.logo, icon: icon),
        title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(_typeLabel(context, item.contentType.name)),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: AppColors.primary),
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
        onTap: () {
          if (item.contentType.name == 'live') {
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
          }
        },
      ),
    );
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
          const Icon(Icons.favorite_border, size: 56, color: AppColors.surfaceVariant),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
