import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/content_type.dart';
import '../../../domain/entities/favorite_item.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/repositories/iptv_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../blocs/favorites/favorites_bloc.dart';
import '../../blocs/favorites/favorites_event.dart';
import '../../blocs/favorites/favorites_state.dart';
import '../../blocs/vod/vod_bloc.dart';
import '../../blocs/vod/vod_event.dart';
import '../../blocs/vod/vod_state.dart';
import '../../shared_widgets/category_sidebar.dart';
import '../../shared_widgets/media_poster.dart';
import '../../shared_widgets/tv_focusable.dart';

/// Catálogo de películas (VOD) con rejilla de pósters y categorías.
class VodScreen extends StatefulWidget {
  const VodScreen({super.key});

  @override
  State<VodScreen> createState() => _VodScreenState();
}

class _VodScreenState extends State<VodScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final VodBloc bloc = context.read<VodBloc>();
      // Solo carga si el catálogo aún no está disponible, para no vaciar la
      // rejilla al volver de una ficha de detalle.
      if (bloc.state is! VodLoaded) {
        bloc.add(const VodStarted());
      }
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

    return BlocBuilder<VodBloc, VodState>(
      builder: (context, state) {
        return switch (state) {
          VodLoading() => const Center(child: CircularProgressIndicator()),
          VodFailure() => _ErrorView(message: l10n.vodLoadError),
          VodLoaded() => _VodContent(state: state, controller: _searchController),
        };
      },
    );
  }
}

/// Contenido del catálogo: buscador, chips de categorías y rejilla de pósters.
class _VodContent extends StatelessWidget {
  const _VodContent({required this.state, required this.controller});

  final VodLoaded state;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: (String value) =>
                      context.read<VodBloc>().add(VodSearchChanged(value)),
                  decoration: InputDecoration(
                    hintText: l10n.searchPlaceholder,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: state.isSearching
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              controller.clear();
                              context
                                  .read<VodBloc>()
                                  .add(const VodSearchChanged(''));
                            },
                          )
                        : null,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: context.colors.surfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Text(l10n.recentlyAdded),
                selected: state.recentOnly,
                onSelected: (bool value) =>
                    context.read<VodBloc>().add(VodRecentToggled(value)),
                avatar: Icon(
                  Icons.new_releases_outlined,
                  size: 18,
                  color: state.recentOnly
                      ? context.colors.onPrimary
                      : context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              CategorySidebar(
                categories: state.categories,
                allLabel: l10n.allCategories,
                isAllSelected: state.isAllSelected,
                selectedCategoryId: state.selectedCategoryId,
                onCategorySelected: (int? id) =>
                    context.read<VodBloc>().add(VodCategorySelected(id)),
                icon: Icons.movie,
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: state.movies.isEmpty
                    ? Center(
                        child: Text(
                          state.isSearching ? l10n.searchNoResults : l10n.noMovies,
                        ),
                      )
                    : BlocBuilder<FavoritesBloc, FavoritesState>(
                        buildWhen: (previous, current) =>
                            current is FavoritesLoaded,
                        builder: (context, favoritesState) {
                          final Set<int> favoriteIds = <int>{};
                          if (favoritesState is FavoritesLoaded) {
                            for (final FavoriteItem item in favoritesState.items) {
                              if (item.contentType.name == ContentType.vod.name) {
                                favoriteIds.add(item.contentId);
                              }
                            }
                          }
                          return GridView.builder(
                            padding: const EdgeInsets.all(12),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 220,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 0.62,
                                ),
                            itemCount: state.movies.length,
                            itemBuilder: (context, index) {
                              final Movie movie = state.movies[index];
                              return _MovieCard(
                                movie: movie,
                                isFavorite: favoriteIds.contains(movie.id),
                                autofocus: index == 0,
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tarjeta de película con póster, título y favorito.
class _MovieCard extends StatelessWidget {
  const _MovieCard({
    required this.movie,
    this.isFavorite = false,
    this.autofocus = false,
  });

  final Movie movie;
  final bool isFavorite;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TvFocusable(
      autofocus: autofocus,
      borderRadius: BorderRadius.circular(8),
      onPressed: () => context.push(Routes.movieDetail, extra: movie),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => context.push(Routes.movieDetail, extra: movie),
        onLongPress: () => _toggleFavorite(context),
        onSecondaryTap: () => _toggleFavorite(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  MediaPoster(
                    url: movie.streamIcon,
                    fallbackIcon: Icons.movie,
                  ),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Icon(
                      Icons.favorite,
                      size: 18,
                      color: isFavorite
                          ? context.colors.secondary
                          : Colors.transparent,
                      semanticLabel:
                          AppLocalizations.of(context)!.favorites,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              movie.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(BuildContext context) async {
    final IptvRepository repository = context.read<IptvRepository>();
    final FavoritesBloc favoritesBloc = context.read<FavoritesBloc>();
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final bool isFav = await repository.isFavorite(
      movie.id,
      ContentType.vod,
    );
    favoritesBloc.add(
      FavoritesToggled(
        movie.id,
        ContentType.vod.name,
        movie.name,
        movie.streamIcon,
      ),
    );
    favoritesBloc.add(FavoritesStarted());

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          isFav ? l10n.removedFromFavorites : l10n.addedToFavorites,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
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
          Icon(Icons.error_outline, size: 56, color: context.colors.error),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: () => context.read<VodBloc>().add(const VodStarted()),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}
