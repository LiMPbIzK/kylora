import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/content_type.dart';
import '../../../domain/entities/favorite_item.dart';
import '../../../domain/entities/series.dart';
import '../../../domain/repositories/iptv_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../blocs/favorites/favorites_bloc.dart';
import '../../blocs/favorites/favorites_event.dart';
import '../../blocs/favorites/favorites_state.dart';
import '../../blocs/series/series_bloc.dart';
import '../../blocs/series/series_event.dart';
import '../../blocs/series/series_state.dart';
import '../../shared_widgets/category_sidebar.dart';
import '../../shared_widgets/media_poster.dart';
import '../../shared_widgets/resume_row.dart';
import '../../shared_widgets/tv_focusable.dart';

/// Catálogo de series con rejilla de portadas y categorías.
class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final SeriesBloc bloc = context.read<SeriesBloc>();
      // Solo carga si el catálogo aún no está disponible, para no vaciar la
      // rejilla al volver de una ficha de detalle.
      if (bloc.state is! SeriesLoaded) {
        bloc.add(const SeriesStarted());
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

    return BlocBuilder<SeriesBloc, SeriesState>(
      builder: (context, state) {
        return switch (state) {
          SeriesLoading() => const Center(child: CircularProgressIndicator()),
          SeriesFailure() => _ErrorView(message: l10n.seriesLoadError),
          SeriesLoaded() => _SeriesContent(
            state: state,
            controller: _searchController,
          ),
          SeriesDetailLoading() ||
          SeriesDetailLoaded() ||
          SeriesDetailFailure() => const SizedBox.shrink(),
        };
      },
    );
  }
}

/// Contenido del catálogo: buscador, chips de categorías y rejilla de portadas.
class _SeriesContent extends StatelessWidget {
  const _SeriesContent({required this.state, required this.controller});

  final SeriesLoaded state;
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
                  onChanged: (String value) => context.read<SeriesBloc>().add(
                    SeriesSearchChanged(value),
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.searchPlaceholder,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: state.isSearching
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              controller.clear();
                              context.read<SeriesBloc>().add(
                                const SeriesSearchChanged(''),
                              );
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
                    context.read<SeriesBloc>().add(SeriesRecentToggled(value)),
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
                selectedCategoryId: state.resumeMode
                    ? null
                    : state.selectedCategoryId,
                onCategorySelected: (int? id) =>
                    context.read<SeriesBloc>().add(SeriesCategorySelected(id)),
                resumeLabel: l10n.continueWatchingSection,
                isResumeSelected: state.resumeMode,
                onResumeSelected: () => context.read<SeriesBloc>().add(
                  SeriesResumeToggled(!state.resumeMode),
                ),
                icon: Icons.theaters,
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: state.resumeMode
                    ? ResumeGrid(contentType: ContentType.series.name)
                    : state.seriesList.isEmpty
                    ? Center(
                        child: Text(
                          state.isSearching
                              ? l10n.searchNoResults
                              : l10n.noSeries,
                        ),
                      )
                    : BlocBuilder<FavoritesBloc, FavoritesState>(
                        buildWhen: (previous, current) =>
                            current is FavoritesLoaded,
                        builder: (context, favoritesState) {
                          final Set<int> favoriteIds = <int>{};
                          if (favoritesState is FavoritesLoaded) {
                            for (final FavoriteItem item
                                in favoritesState.items) {
                              if (item.contentType.name ==
                                  ContentType.series.name) {
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
                            itemCount: state.seriesList.length,
                            itemBuilder: (context, index) {
                              final Series series = state.seriesList[index];
                              return _SeriesCard(
                                series: series,
                                isFavorite: favoriteIds.contains(series.id),
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

/// Tarjeta de serie con portada, título y favorito.
class _SeriesCard extends StatelessWidget {
  const _SeriesCard({
    required this.series,
    this.isFavorite = false,
    this.autofocus = false,
  });

  final Series series;
  final bool isFavorite;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TvFocusable(
      autofocus: autofocus,
      borderRadius: BorderRadius.circular(8),
      onPressed: () => context.push(Routes.seriesDetail, extra: series),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => context.push(Routes.seriesDetail, extra: series),
        onLongPress: () => _toggleFavorite(context),
        onSecondaryTap: () => _toggleFavorite(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  MediaPoster(url: series.cover, fallbackIcon: Icons.theaters),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Icon(
                      Icons.favorite,
                      size: 18,
                      color: isFavorite
                          ? context.colors.secondary
                          : Colors.transparent,
                      semanticLabel: AppLocalizations.of(context)!.favorites,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              series.name,
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
      series.id,
      ContentType.series,
    );
    favoritesBloc.add(
      FavoritesToggled(
        series.id,
        ContentType.series.name,
        series.name,
        series.cover,
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
            onPressed: () =>
                context.read<SeriesBloc>().add(const SeriesStarted()),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}
