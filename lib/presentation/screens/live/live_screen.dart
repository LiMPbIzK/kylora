import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app.dart';
import '../../../core/media/playback_controller.dart';
import '../../../core/media/playback_request.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/channel.dart';
import '../../../domain/entities/content_type.dart';
import '../../../domain/entities/epg.dart';
import '../../../domain/entities/favorite_channel_group.dart';
import '../../../domain/entities/favorite_item.dart';
import '../../../domain/repositories/iptv_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../blocs/epg/epg_bloc.dart';
import '../../blocs/epg/epg_event.dart';
import '../../blocs/epg/epg_state.dart';
import '../../blocs/favorites/favorites_bloc.dart';
import '../../blocs/favorites/favorites_event.dart';
import '../../blocs/favorites/favorites_state.dart';
import '../../blocs/live/live_bloc.dart';
import '../../blocs/live/live_event.dart';
import '../../blocs/live/live_state.dart';
import '../../blocs/search/search_visibility_cubit.dart';
import '../../shared_widgets/catalog_search_field.dart';
import '../../shared_widgets/category_sidebar.dart';
import '../../shared_widgets/tv_context_menu.dart';
import '../../shared_widgets/tv_focusable.dart';
import '../../shared_widgets/tv_marquee_text.dart';
import '../player/playback_scope.dart';

/// Catálogo de canales en directo con buscador, categorías a la izquierda y
/// rejilla de tarjetas.
///
/// Layout orientado a Android TV: las secciones se seleccionan en una columna
/// vertical a la izquierda y los canales se muestran en una rejilla de tarjetas
/// cuadradas. Un toque reproduce el canal; una pulsación prolongada alterna el
/// favorito mostrando un mensaje con la acción realizada.
///
/// Con [radio] activo muestra solo las categorías de radio (streams de audio)
/// y oculta la información de EPG, que no aplica a las emisoras.
class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key, this.radio = false});

  final bool radio;

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _firstResultFocus = FocusNode();
  final FocusNode _firstCategoryFocus = FocusNode();

  PlaybackController? _playback;
  bool _wasPlaying = false;

  @override
  void initState() {
    super.initState();
    // La carga se dispara al montar la pantalla para no depender de la navegación.
    final bool radio = widget.radio;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LiveBloc>().add(LiveStarted(radio: radio));
      context.read<FavoritesBloc>().add(const FavoritesStarted());
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

    return BlocListener<LiveBloc, LiveState>(
      // Al limpiar la búsqueda desde la lupa, vacía también el texto del cuadro
      // para que no reaparezca al volver a abrirlo.
      listenWhen: (LiveState previous, LiveState current) =>
          previous is LiveLoaded &&
          previous.isSearching &&
          current is LiveLoaded &&
          !current.isSearching,
      listener: (context, state) => _searchController.clear(),
      child: BlocBuilder<LiveBloc, LiveState>(
        builder: (context, state) {
          return switch (state) {
            LiveLoading() => const Center(child: CircularProgressIndicator()),
            LiveFailure() => _ErrorView(
              message: l10n.liveLoadError,
              radio: widget.radio,
            ),
            LiveLoaded() => _LiveContent(
              state: state,
              controller: _searchController,
              firstResultFocus: _firstResultFocus,
              firstCategoryFocus: _firstCategoryFocus,
              showEpg: !widget.radio,
              radio: widget.radio,
            ),
          };
        },
      ),
    );
  }
}

/// Contenido del catálogo: buscador, categorías verticales y rejilla de canales.
class _LiveContent extends StatelessWidget {
  const _LiveContent({
    required this.state,
    required this.controller,
    required this.firstResultFocus,
    required this.firstCategoryFocus,
    required this.showEpg,
    required this.radio,
  });

  final LiveLoaded state;
  final TextEditingController controller;
  final FocusNode firstResultFocus;
  final FocusNode firstCategoryFocus;

  /// `false` en la sección Radio: no se consulta ni muestra EPG.
  final bool showEpg;
  final bool radio;

  Future<void> _showGroupMenu(BuildContext context, Category category) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final FavoritesState favoritesState = context.read<FavoritesBloc>().state;
    final bool isFavorite =
        favoritesState is FavoritesLoaded &&
        favoritesState.groups.any(
          (FavoriteChannelGroup group) => group.categoryId == category.id,
        );
    final bool? selected = await showTvContextMenu<bool>(
      context: context,
      entries: <TvContextMenuEntry<bool>>[
        TvContextMenuEntry<bool>(
          value: true,
          icon: isFavorite ? Icons.star : Icons.star_border,
          label: isFavorite
              ? l10n.removeGroupFromFavorites
              : l10n.addGroupToFavorites,
        ),
      ],
    );
    if (selected == null || !context.mounted) return;
    context.read<FavoritesBloc>().add(
      FavoriteGroupToggled(
        FavoriteChannelGroup(
          categoryId: category.id,
          name: category.name,
          isRadio: radio,
          addedAt: DateTime.now(),
        ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite ? l10n.groupFavoriteRemoved : l10n.groupFavoriteAdded,
        ),
      ),
    );
  }

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
                  context.read<LiveBloc>().add(LiveSearchChanged(value)),
              onClose: () {
                controller.clear();
                context.read<LiveBloc>().add(const LiveSearchChanged(''));
                context.read<SearchVisibilityCubit>().hide();
                _focusFirstCategory();
              },
              onDismiss: () => context.read<SearchVisibilityCubit>().hide(),
              upFocus: firstCategoryFocus,
              downFocus: firstResultFocus,
              onSearchSubmitted: () {},
            );
          },
        ),
        const Divider(height: 1),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              BlocBuilder<FavoritesBloc, FavoritesState>(
                buildWhen: (previous, current) => current is FavoritesLoaded,
                builder: (context, favoritesState) {
                  final Set<int> favoriteGroupIds =
                      favoritesState is FavoritesLoaded
                      ? favoritesState.groups
                            .map(
                              (FavoriteChannelGroup group) => group.categoryId,
                            )
                            .toSet()
                      : const <int>{};
                  return CategorySidebar(
                    categories: state.categories,
                    selectedCategoryId: state.selectedCategoryId,
                    favoriteGroupIds: favoriteGroupIds,
                    onCategorySelected: (int? id) =>
                        context.read<LiveBloc>().add(LiveCategorySelected(id)),
                    onCategoryLongPress: (Category category) =>
                        _showGroupMenu(context, category),
                    firstCategoryFocus: firstCategoryFocus,
                  );
                },
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: state.channels.isEmpty
                    ? Center(
                        child: Text(
                          state.isSearching
                              ? l10n.searchNoResults
                              : l10n.noChannels,
                        ),
                      )
                    : _ChannelsGrid(
                        channels: state.channels,
                        firstResultFocus: firstResultFocus,
                        showEpg: showEpg,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Rejilla de tarjetas cuadradas de canales.
class _ChannelsGrid extends StatelessWidget {
  const _ChannelsGrid({
    required this.channels,
    required this.showEpg,
    this.firstResultFocus,
  });

  final List<Channel> channels;
  final bool showEpg;
  final FocusNode? firstResultFocus;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      buildWhen: (previous, current) => current is FavoritesLoaded,
      builder: (context, favoritesState) {
        final Set<int> favoriteIds = <int>{};
        if (favoritesState is FavoritesLoaded) {
          for (final FavoriteItem item in favoritesState.items) {
            if (item.contentType.name == 'live') {
              favoriteIds.add(item.contentId);
            }
          }
        }
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: channels.length,
          itemBuilder: (context, index) {
            return _ChannelCard(
              channel: channels[index],
              isFavorite: favoriteIds.contains(channels[index].id),
              autofocus: false,
              focusNode: index == 0 ? firstResultFocus : null,
              showEpg: showEpg,
            );
          },
        );
      },
    );
  }
}

/// Tarjeta cuadrada de canal: logo, botón de guía y reproducción/favorito.
/// Acciones disponibles en el menú contextual de una tarjeta de canal.
enum _ChannelAction { play, favorite, guide }

class _ChannelCard extends StatefulWidget {
  const _ChannelCard({
    required this.channel,
    required this.showEpg,
    this.isFavorite = false,
    this.autofocus = false,
    this.focusNode,
  });

  final Channel channel;
  final bool showEpg;
  final bool isFavorite;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  State<_ChannelCard> createState() => _ChannelCardState();
}

class _ChannelCardState extends State<_ChannelCard> {
  bool _hasGuide = false;
  FocusNode? _internalFocusNode;

  FocusNode get _cardFocusNode =>
      widget.focusNode ??
      (_internalFocusNode ??= FocusNode(debugLabel: 'channel-card'));

  @override
  void initState() {
    super.initState();
    // Carga el EPG corto (ahora/siguiente) del canal si aún no está en caché.
    // En radio no hay EPG, así que se evita la petición.
    if (widget.showEpg) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<EpgBloc>().add(EpgNowNextRequested(widget.channel.id));
        }
      });
    }
  }

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EpgBloc, EpgState>(
      buildWhen: (previous, current) =>
          current is EpgNowNextLoaded && current.streamId == widget.channel.id,
      builder: (context, epgState) {
        final bool hasGuide =
            widget.showEpg && epgState is EpgNowNextLoaded && epgState.hasGuide;
        _hasGuide = hasGuide;
        final AppColors colors = context.colors;
        return TvFocusable(
          autofocus: widget.autofocus,
          focusNode: _cardFocusNode,
          onPressed: _play,
          onLongPress: _showContextMenu,
          borderRadius: BorderRadius.circular(10),
          child: Material(
            color: colors.surface,
            borderRadius: BorderRadius.circular(10),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              canRequestFocus: false,
              onTap: _play,
              onLongPress: _showContextMenu,
              onSecondaryTap: _showContextMenu,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        _ChannelLogo(logo: widget.channel.logo),
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Icon(
                            Icons.favorite,
                            color: widget.isFavorite
                                ? colors.secondary
                                : Colors.transparent,
                            size: 22,
                            semanticLabel: AppLocalizations.of(context)!
                                .favorites,
                          ),
                        ),
                        if (hasGuide)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IgnorePointer(
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  Icons.calendar_view_day,
                                  color: colors.primary,
                                  size: 22,
                                  semanticLabel: AppLocalizations.of(context)!
                                      .epgGuide,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TvMarqueeText(
                          text: widget.channel.name,
                          maxLines: 1,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (widget.showEpg)
                          _EpgLine(streamId: widget.channel.id),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
        hasArchive: widget.channel.hasArchive,
        archiveDurationDays: widget.channel.archiveDurationDays,
        channelTitle: widget.channel.name,
      ),
    );
  }

  Future<void> _showContextMenu() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final _ChannelAction? action = await showTvContextMenu<_ChannelAction>(
      context: context,
      entries: <TvContextMenuEntry<_ChannelAction>>[
        TvContextMenuEntry<_ChannelAction>(
          value: _ChannelAction.play,
          icon: Icons.play_arrow,
          label: l10n.play,
        ),
        TvContextMenuEntry<_ChannelAction>(
          value: _ChannelAction.favorite,
          icon: widget.isFavorite ? Icons.favorite : Icons.favorite_border,
          iconColor: widget.isFavorite ? context.colors.secondary : null,
          label: l10n.favorites,
        ),
        if (_hasGuide)
          TvContextMenuEntry<_ChannelAction>(
            value: _ChannelAction.guide,
            icon: Icons.calendar_view_day,
            label: l10n.epgGuide,
          ),
      ],
    );

    if (!mounted) return;
    // El foco vuelve a la tarjeta antes de reproducir para que el reproductor
    // guarde este nodo y lo restaure al cerrar el vídeo.
    _cardFocusNode.requestFocus();
    switch (action) {
      case _ChannelAction.play:
        _play();
      case _ChannelAction.favorite:
        await _toggleFavorite();
      case _ChannelAction.guide:
        // La guía se consulta sin arrancar el canal. Desde ella se puede
        // entrar con el botón de reproducir.
        context.push(Routes.programGuide, extra: widget.channel);
      case null:
        break;
    }
  }

  Future<void> _toggleFavorite() async {
    final IptvRepository repository = context.read<IptvRepository>();
    final FavoritesBloc favoritesBloc = context.read<FavoritesBloc>();
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final bool isFav = await repository.isFavorite(
      widget.channel.id,
      ContentType.live,
    );
    favoritesBloc.add(
      FavoritesToggled(
        widget.channel.id,
        ContentType.live.name,
        widget.channel.name,
        widget.channel.logo,
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

/// Línea que muestra el programa actual y el siguiente de un canal.
class _EpgLine extends StatelessWidget {
  const _EpgLine({required this.streamId});

  final int streamId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EpgBloc, EpgState>(
      buildWhen: (previous, current) =>
          current is EpgNowNextLoaded && current.streamId == streamId,
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
      return _fallbackLogo(context);
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.contain,
      placeholder: (context, url) => _fallbackLogo(context),
      errorWidget: (context, url, error) => _fallbackLogo(context),
    );
  }

  Widget _fallbackLogo(BuildContext context) => Container(
    color: context.colors.surfaceVariant,
    alignment: Alignment.center,
    child: Icon(Icons.tv, color: context.colors.primary, size: 32),
  );
}

/// Vista de error de carga del catálogo.
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.radio});

  final String message;
  final bool radio;

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
                context.read<LiveBloc>().add(LiveStarted(radio: radio)),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}
