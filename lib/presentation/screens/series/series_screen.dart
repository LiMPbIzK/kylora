import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app.dart';
import '../../../core/media/playback_controller.dart';
import '../../../core/media/playback_request.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/content_type.dart';
import '../../../domain/entities/episode.dart';
import '../../../domain/entities/favorite_item.dart';
import '../../../domain/entities/season.dart';
import '../../../domain/entities/series.dart';
import '../../../domain/entities/series_info.dart';
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
import '../../shared_widgets/tv_context_menu.dart';
import '../../shared_widgets/tv_focusable.dart';
import '../../shared_widgets/tv_marquee_text.dart';
import '../player/playback_scope.dart';

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

  PlaybackController? _playback;
  bool _wasPlaying = false;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final PlaybackController controller = PlaybackScope.of(context);
    if (!identical(controller, _playback)) {
      _playback?.removeListener(_onPlaybackChanged);
      _playback = controller..addListener(_onPlaybackChanged);
      _wasPlaying = controller.isPlaying;
    }
  }

  /// Si al cerrar el reproductor el overlay no pudo devolver el foco a la
  /// tarjeta, deja el foco en la categoría seleccionada para que el D-Pad siga
  /// respondiendo.
  void _onPlaybackChanged() {
    final bool playing = _playback?.isPlaying ?? false;
    if (playing == _wasPlaying) return;
    _wasPlaying = playing;
    if (playing) return;
    Future<void>.delayed(const Duration(milliseconds: 220), () {
      if (!mounted) return;
      if (ModalRoute.of(context)?.isCurrent != true) return;
      if (FocusScope.of(context).hasFocus) return;
      if (_firstCategoryFocus.context != null) {
        _firstCategoryFocus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _playback?.removeListener(_onPlaybackChanged);
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
                                autofocus: false,
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

/// Acciones del menú contextual de una tarjeta de serie.
enum _SeriesAction { play, favorite, details }

/// Tarjeta de serie con portada, título y favorito.
class _SeriesCard extends StatefulWidget {
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
  State<_SeriesCard> createState() => _SeriesCardState();
}

class _SeriesCardState extends State<_SeriesCard> {
  FocusNode? _internalFocusNode;

  FocusNode get _cardFocusNode =>
      widget.focusNode ??
      (_internalFocusNode ??= FocusNode(debugLabel: 'series-card'));

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _openDetails() {
    context.push(Routes.seriesDetail, extra: widget.series);
  }

  @override
  Widget build(BuildContext context) {
    return TvFocusable(
      autofocus: widget.autofocus,
      focusNode: _cardFocusNode,
      borderRadius: BorderRadius.circular(8),
      onPressed: _openDetails,
      onLongPress: _showContextMenu,
      child: InkWell(
        canRequestFocus: false,
        borderRadius: BorderRadius.circular(8),
        onTap: _openDetails,
        onLongPress: _showContextMenu,
        onSecondaryTap: _showContextMenu,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  MediaPoster(
                    url: widget.series.cover,
                    fallbackIcon: Icons.theaters,
                  ),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Icon(
                      Icons.favorite,
                      size: 18,
                      color: widget.isFavorite
                          ? context.colors.secondary
                          : Colors.transparent,
                      semanticLabel: AppLocalizations.of(context)!.favorites,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            TvMarqueeText(
              text: widget.series.name,
              maxLines: 2,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showContextMenu() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final _SeriesAction? action = await showTvContextMenu<_SeriesAction>(
      context: context,
      entries: <TvContextMenuEntry<_SeriesAction>>[
        TvContextMenuEntry<_SeriesAction>(
          value: _SeriesAction.play,
          icon: Icons.play_arrow,
          label: l10n.play,
        ),
        TvContextMenuEntry<_SeriesAction>(
          value: _SeriesAction.favorite,
          icon: widget.isFavorite ? Icons.favorite : Icons.favorite_border,
          iconColor: widget.isFavorite ? context.colors.secondary : null,
          label: l10n.favorites,
        ),
        TvContextMenuEntry<_SeriesAction>(
          value: _SeriesAction.details,
          icon: Icons.info_outline,
          label: l10n.viewDetails,
        ),
      ],
    );

    if (!mounted) return;
    // El foco vuelve a la tarjeta antes de reproducir para que el reproductor
    // guarde este nodo y lo restaure al cerrar el vídeo.
    _cardFocusNode.requestFocus();
    switch (action) {
      case _SeriesAction.play:
        await _play();
      case _SeriesAction.favorite:
        await _toggleFavorite();
      case _SeriesAction.details:
        _openDetails();
      case null:
        break;
    }
  }

  /// Reproduce el primer episodio disponible de la serie.
  ///
  /// Una serie no tiene un stream único; para el acceso rápido se usa el primer
  /// episodio (la ficha permite elegir cualquier otro).
  Future<void> _play() async {
    final IptvRepository repository = context.read<IptvRepository>();
    final PlaybackController playback = PlaybackScope.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      final SeriesInfo info = await repository.fetchSeriesInfo(
        widget.series.id,
      );
      final List<Season> seasons = List<Season>.of(info.seasons)
        ..sort((Season a, Season b) => a.number.compareTo(b.number));
      Episode? first;
      for (final Season season in seasons) {
        if (season.episodes.isEmpty) continue;
        final List<Episode> episodes = List<Episode>.of(season.episodes)
          ..sort(
            (Episode a, Episode b) =>
                a.episodeNumber.compareTo(b.episodeNumber),
          );
        first = episodes.first;
        break;
      }
      if (first == null) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.seriesDetailLoadError)),
        );
        return;
      }
      final Episode episode = first;
      final String episodeName = episode.name.isEmpty
          ? 'E${episode.episodeNumber}'
          : episode.name;
      playback.play(
        PlaybackRequest(
          title: '${widget.series.name} — $episodeName',
          urlBuilder: () => repository.buildEpisodeStreamUrl(episode),
          contentType: 'series',
          contentId: episode.id,
          logo: widget.series.cover,
        ),
      );
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.seriesDetailLoadError)),
      );
    }
  }

  Future<void> _toggleFavorite() async {
    final IptvRepository repository = context.read<IptvRepository>();
    final FavoritesBloc favoritesBloc = context.read<FavoritesBloc>();
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final bool isFav = await repository.isFavorite(
      widget.series.id,
      ContentType.series,
    );
    favoritesBloc.add(
      FavoritesToggled(
        widget.series.id,
        ContentType.series.name,
        widget.series.name,
        widget.series.cover,
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
