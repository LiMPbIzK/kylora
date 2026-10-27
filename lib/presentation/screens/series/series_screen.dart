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
import '../../blocs/search/search_visibility_cubit.dart';
import '../../blocs/series/series_bloc.dart';
import '../../blocs/series/series_event.dart';
import '../../blocs/series/series_state.dart';
import '../../shared_widgets/catalog_search_field.dart';
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
  final FocusNode _firstResultFocus = FocusNode();
  final FocusNode _firstCategoryFocus = FocusNode();

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
    _firstResultFocus.dispose();
    _firstCategoryFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return BlocListener<SeriesBloc, SeriesState>(
      // Al limpiar la búsqueda desde la lupa, vacía también el texto del cuadro
      // para que no reaparezca al volver a abrirlo.
      listenWhen: (SeriesState previous, SeriesState current) =>
          previous is SeriesLoaded &&
          previous.isSearching &&
          current is SeriesLoaded &&
          !current.isSearching,
      listener: (context, state) => _searchController.clear(),
      child: BlocBuilder<SeriesBloc, SeriesState>(
        builder: (context, state) {
          return switch (state) {
            SeriesLoading() => const Center(child: CircularProgressIndicator()),
            SeriesFailure() => _ErrorView(message: l10n.seriesLoadError),
            SeriesLoaded() => _SeriesContent(
              state: state,
              controller: _searchController,
              firstResultFocus: _firstResultFocus,
              firstCategoryFocus: _firstCategoryFocus,
            ),
            SeriesDetailLoading() ||
            SeriesDetailLoaded() ||
            SeriesDetailFailure() => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

/// Contenido del catálogo: buscador, chips de categorías y rejilla de portadas.
class _SeriesContent extends StatelessWidget {
  const _SeriesContent({
    required this.state,
    required this.controller,
    required this.firstResultFocus,
    required this.firstCategoryFocus,
  });

  final SeriesLoaded state;
  final TextEditingController controller;
  final FocusNode firstResultFocus;
  final FocusNode firstCategoryFocus;

  /// Devuelve el foco a la primera sección tras cerrar el buscador.
  void _focusFirstCategory() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      firstCategoryFocus.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Column(
      children: <Widget>[
        BlocBuilder<SearchVisibilityCubit, bool>(
          builder: (context, searchVisible) {
            if (!searchVisible) return const SizedBox.shrink();
            return CatalogSearchField(
              controller: controller,
              hintText: l10n.searchPlaceholder,
              onChanged: (String value) =>
                  context.read<SeriesBloc>().add(SeriesSearchChanged(value)),
              onClose: () {
                controller.clear();
                context.read<SeriesBloc>().add(const SeriesSearchChanged(''));
                context.read<SearchVisibilityCubit>().hide();
                _focusFirstCategory();
              },
              onDismiss: () => context.read<SearchVisibilityCubit>().hide(),
              upFocus: firstCategoryFocus,
              downFocus: firstResultFocus,
              onSearchSubmitted: () {},
              trailing: FilterChip(
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
            );
          },
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
                firstCategoryFocus: firstCategoryFocus,
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
                                focusNode: index == 0 ? firstResultFocus : null,
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
    this.focusNode,
  });

  final Series series;
  final bool isFavorite;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return TvFocusable(
      autofocus: autofocus,
      focusNode: focusNode,
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
