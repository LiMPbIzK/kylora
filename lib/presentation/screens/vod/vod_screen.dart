import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app.dart';
import '../../../core/media/playback_controller.dart';
import '../../../core/media/playback_request.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/content_type.dart';
import '../../../domain/entities/favorite_item.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/repositories/iptv_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../blocs/favorites/favorites_bloc.dart';
import '../../blocs/favorites/favorites_event.dart';
import '../../blocs/favorites/favorites_state.dart';
import '../../blocs/search/search_visibility_cubit.dart';
import '../../blocs/vod/vod_bloc.dart';
import '../../blocs/vod/vod_event.dart';
import '../../blocs/vod/vod_state.dart';
import '../../shared_widgets/catalog_search_field.dart';
import '../../shared_widgets/category_sidebar.dart';
import '../../shared_widgets/media_poster.dart';
import '../../shared_widgets/resume_row.dart';
import '../../shared_widgets/tv_context_menu.dart';
import '../../shared_widgets/tv_focusable.dart';
import '../../shared_widgets/tv_marquee_text.dart';
import '../player/playback_scope.dart';

/// Catálogo de películas (VOD) con rejilla de pósters y categorías.
class VodScreen extends StatefulWidget {
  const VodScreen({super.key});

  @override
  State<VodScreen> createState() => _VodScreenState();
}

class _VodScreenState extends State<VodScreen> {
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
      final VodBloc bloc = context.read<VodBloc>();
      // Solo carga si el catálogo aún no está disponible, para no vaciar la
      // rejilla al volver de una ficha de detalle.
      if (bloc.state is! VodLoaded) {
        bloc.add(const VodStarted());
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

    return BlocListener<VodBloc, VodState>(
      // Al limpiar la búsqueda desde la lupa, vacía también el texto del cuadro
      // para que no reaparezca al volver a abrirlo.
      listenWhen: (VodState previous, VodState current) =>
          previous is VodLoaded &&
          previous.isSearching &&
          current is VodLoaded &&
          !current.isSearching,
      listener: (context, state) => _searchController.clear(),
      child: BlocBuilder<VodBloc, VodState>(
        builder: (context, state) {
          return switch (state) {
            VodLoading() => const Center(child: CircularProgressIndicator()),
            VodFailure() => _ErrorView(message: l10n.vodLoadError),
            VodLoaded() => _VodContent(
              state: state,
              controller: _searchController,
              firstResultFocus: _firstResultFocus,
              firstCategoryFocus: _firstCategoryFocus,
            ),
          };
        },
      ),
    );
  }
}

/// Contenido del catálogo: buscador, chips de categorías y rejilla de pósters.
class _VodContent extends StatelessWidget {
  const _VodContent({
    required this.state,
    required this.controller,
    required this.firstResultFocus,
    required this.firstCategoryFocus,
  });

  final VodLoaded state;
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
                  context.read<VodBloc>().add(VodSearchChanged(value)),
              onClose: () {
                controller.clear();
                context.read<VodBloc>().add(const VodSearchChanged(''));
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
                    context.read<VodBloc>().add(VodRecentToggled(value)),
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
                onCategorySelected: (int? id) {
                  context.read<VodBloc>().add(VodCategorySelected(id));
                },
                resumeLabel: l10n.continueWatchingSection,
                isResumeSelected: state.resumeMode,
                onResumeSelected: () => context.read<VodBloc>().add(
                  VodResumeToggled(!state.resumeMode),
                ),
                firstCategoryFocus: firstCategoryFocus,
                icon: Icons.movie,
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: state.resumeMode
                    ? ResumeGrid(contentType: ContentType.vod.name)
                    : state.movies.isEmpty
                    ? Center(
                        child: Text(
                          state.isSearching
                              ? l10n.searchNoResults
                              : l10n.noMovies,
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
                                  ContentType.vod.name) {
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

/// Acciones del menú contextual de una tarjeta de película.
enum _MovieAction { play, favorite, details }

/// Tarjeta de película con póster, título y favorito.
class _MovieCard extends StatefulWidget {
  const _MovieCard({
    required this.movie,
    this.isFavorite = false,
    this.autofocus = false,
    this.focusNode,
  });

  final Movie movie;
  final bool isFavorite;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  State<_MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<_MovieCard> {
  FocusNode? _internalFocusNode;

  FocusNode get _cardFocusNode =>
      widget.focusNode ??
      (_internalFocusNode ??= FocusNode(debugLabel: 'movie-card'));

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _openDetails() {
    context.push(Routes.movieDetail, extra: widget.movie);
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
                    url: widget.movie.streamIcon,
                    fallbackIcon: Icons.movie,
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
              text: widget.movie.name,
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
    final _MovieAction? action = await showTvContextMenu<_MovieAction>(
      context: context,
      entries: <TvContextMenuEntry<_MovieAction>>[
        TvContextMenuEntry<_MovieAction>(
          value: _MovieAction.play,
          icon: Icons.play_arrow,
          label: l10n.play,
        ),
        TvContextMenuEntry<_MovieAction>(
          value: _MovieAction.favorite,
          icon: widget.isFavorite ? Icons.favorite : Icons.favorite_border,
          iconColor: widget.isFavorite ? context.colors.secondary : null,
          label: l10n.favorites,
        ),
        TvContextMenuEntry<_MovieAction>(
          value: _MovieAction.details,
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
      case _MovieAction.play:
        _play();
      case _MovieAction.favorite:
        await _toggleFavorite();
      case _MovieAction.details:
        _openDetails();
      case null:
        break;
    }
  }

  void _play() {
    final IptvRepository repository = context.read<IptvRepository>();
    PlaybackScope.of(context).play(
      PlaybackRequest(
        title: widget.movie.name,
        urlBuilder: () => repository.buildVodStreamUrl(widget.movie),
        contentType: 'vod',
        contentId: widget.movie.id,
        logo: widget.movie.streamIcon,
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    final IptvRepository repository = context.read<IptvRepository>();
    final FavoritesBloc favoritesBloc = context.read<FavoritesBloc>();
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final bool isFav = await repository.isFavorite(
      widget.movie.id,
      ContentType.vod,
    );
    favoritesBloc.add(
      FavoritesToggled(
        widget.movie.id,
        ContentType.vod.name,
        widget.movie.name,
        widget.movie.streamIcon,
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
