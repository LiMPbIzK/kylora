import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemNavigator;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app.dart';
import '../../../core/media/playback_controller.dart';
import '../../../core/reminders/epg_reminder_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/clock_format.dart';
import '../../../l10n/app_localizations.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/epg/epg_bloc.dart';
import '../../blocs/epg/epg_event.dart';
import '../../blocs/favorites/favorites_bloc.dart';
import '../../blocs/favorites/favorites_event.dart';
import '../../blocs/history/history_bloc.dart';
import '../../blocs/history/history_event.dart';
import '../../blocs/live/live_bloc.dart';
import '../../blocs/live/live_event.dart';
import '../../blocs/live/live_state.dart';
import '../../blocs/search/search_visibility_cubit.dart';
import '../../blocs/series/series_bloc.dart';
import '../../blocs/series/series_event.dart';
import '../../blocs/series/series_state.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../blocs/settings/settings_state.dart';
import '../../blocs/vod/vod_bloc.dart';
import '../../blocs/vod/vod_event.dart';
import '../../blocs/vod/vod_state.dart';
import '../../shared_widgets/continue_watching_row.dart';
import '../../shared_widgets/tv_focusable.dart';
import '../live/live_screen.dart';
import '../player/playback_scope.dart';
import '../series/series_screen.dart';
import '../vod/vod_screen.dart';

/// Secciones principales de la aplicación.
enum _DashboardSection { live, vod, series, radio }

/// Pantalla principal autenticada.
///
/// Muestra primero un selector de secciones (TV, Películas, Series y Radio).
/// Al elegir una, solo se ve el contenido de esa sección; para cambiar hay que
/// volver atrás al selector (botón Atrás o flecha de la barra superior).
class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({super.key});

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  /// Sección abierta; `null` muestra el selector de secciones.
  _DashboardSection? _section;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<HistoryBloc>().add(const HistoryStarted());
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool inSection = _section != null;

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (AuthState previous, AuthState current) =>
          current is AuthAuthenticated &&
          (previous is! AuthAuthenticated ||
              previous.activeAccountId != current.activeAccountId),
      listener: (BuildContext context, AuthState state) => _onAccountChanged(),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          if (didPop) return;
          final bool shouldExit = await _handleBack();
          if (shouldExit && context.mounted) {
            // GoRouter no puede hacer pop desde la raíz; salida del sistema.
            SystemNavigator.pop();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            // Reloj centrado en la barra superior (visible en el selector y en
            // todas las secciones). El reproductor a pantalla completa lo tapa.
            flexibleSpace: const _AppClock(),
            leading: inSection
                ? IconButton(
                    tooltip: MaterialLocalizations.of(context)
                        .backButtonTooltip,
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _goToSections,
                  )
                : null,
            title: Text(_sectionTitle(l10n, _section)),
            actions: <Widget>[
              if (inSection)
                _buildSearchAction(l10n)
              else
                IconButton(
                  tooltip: l10n.searchPlaceholder,
                  icon: const Icon(Icons.search),
                  onPressed: () => context.push(Routes.search),
                ),
              IconButton(
                tooltip: l10n.favorites,
                icon: const Icon(Icons.favorite_border),
                onPressed: () => context.push(Routes.favorites),
              ),
              IconButton(
                tooltip: l10n.history,
                icon: const Icon(Icons.history),
                onPressed: () => context.push(Routes.history),
              ),
              IconButton(
                tooltip: l10n.settings,
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.push(Routes.settings),
              ),
            ],
          ),
          body: _section == null
              ? _SectionsHome(onSelected: _openSection)
              : _buildSection(_section!),
        ),
      ),
    );
  }

  /// Al cambiar de cuenta: corta la reproducción y vacía los catálogos/EPG
  /// para que la siguiente sección cargue los datos de la cuenta activa.
  void _onAccountChanged() {
    PlaybackScope.of(context).stop();
    EpgReminderService.instance.clear();
    context.read<SearchVisibilityCubit>().hide();
    setState(() => _section = null);
    context.read<LiveBloc>().add(const LiveStarted());
    context.read<VodBloc>().add(const VodStarted());
    context.read<SeriesBloc>().add(const SeriesStarted());
    context.read<FavoritesBloc>().add(const FavoritesStarted());
    context.read<HistoryBloc>().add(const HistoryStarted());
    context.read<EpgBloc>().add(const EpgCleared());
  }

  String _sectionTitle(AppLocalizations l10n, _DashboardSection? section) {
    return switch (section) {
      _DashboardSection.live => l10n.liveTv,
      _DashboardSection.vod => l10n.movies,
      _DashboardSection.series => l10n.series,
      _DashboardSection.radio => l10n.radio,
      null => 'Kylora',
    };
  }

  Widget _buildSection(_DashboardSection section) {
    return switch (section) {
      _DashboardSection.live => const LiveScreen(),
      _DashboardSection.vod => const VodScreen(),
      _DashboardSection.series => const SeriesScreen(),
      _DashboardSection.radio => const LiveScreen(radio: true),
    };
  }

  /// Abre una sección y oculta el buscador de la sección anterior (si estaba
  /// visible) para que no aparezca al entrar en la nueva.
  void _openSection(_DashboardSection section) {
    context.read<SearchVisibilityCubit>().hide();
    setState(() => _section = section);
  }

  /// Vuelve al selector de secciones.
  void _goToSections() {
    context.read<SearchVisibilityCubit>().hide();
    setState(() => _section = null);
  }

  /// Maneja el botón Atrás del mando/TV:
  /// 1. Si hay un stream en reproducción, el reproductor oculta primero el OSD
  ///    o cierra la reproducción (vuelve al menú). Nunca sale de la app.
  /// 2. Si hay una sección abierta, vuelve al selector de secciones.
  /// 3. En el selector, muestra el diálogo "¿Salir?".
  ///
  /// Devuelve `true` SOLO cuando el usuario confirma salir de la aplicación.
  Future<bool> _handleBack() async {
    final PlaybackController playback = PlaybackScope.of(context);
    if (playback.isPlaying) {
      final bool consumed = playback.onPlayerBack?.call() ?? false;
      if (!consumed) playback.stop();
      // Consumimos el back del reproductor: NO salir de la app.
      return false;
    }
    if (_section != null) {
      _goToSections();
      return false;
    }
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool? exitApp = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.exitAppTitle),
        content: Text(l10n.exitAppConfirm),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.exitApp),
          ),
        ],
      ),
    );
    return exitApp ?? false;
  }

  /// Acción de la barra superior para el buscador.
  ///
  /// Con una búsqueda activa en la sección visible muestra la lupa con una X y
  /// al pulsarla limpia el filtro (las categorías vuelven a estar disponibles).
  /// Sin búsqueda, abre/cierra el cuadro de búsqueda como antes.
  Widget _buildSearchAction(AppLocalizations l10n) {
    return BlocBuilder<LiveBloc, LiveState>(
      builder: (context, liveState) {
        return BlocBuilder<VodBloc, VodState>(
          builder: (context, vodState) {
            return BlocBuilder<SeriesBloc, SeriesState>(
              builder: (context, seriesState) {
                return BlocBuilder<SearchVisibilityCubit, bool>(
                  builder: (context, searchVisible) {
                    final bool activeSearch = switch (_section) {
                      _DashboardSection.vod =>
                        vodState is VodLoaded && vodState.isSearching,
                      _DashboardSection.series =>
                        seriesState is SeriesLoaded && seriesState.isSearching,
                      _DashboardSection.live || _DashboardSection.radio =>
                        liveState is LiveLoaded && liveState.isSearching,
                      null => false,
                    };
                    if (activeSearch) {
                      return IconButton(
                        tooltip: l10n.clearSearch,
                        icon: _buildSearchIcon(),
                        onPressed: _clearSearch,
                      );
                    }
                    return IconButton(
                      tooltip: l10n.searchPlaceholder,
                      icon: Icon(
                        searchVisible ? Icons.search_off : Icons.search,
                      ),
                      onPressed: () => _toggleSearch(searchVisible),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  /// Alterna la visibilidad del buscador. No borra la búsqueda activa: para
  /// limpiarla se usa la X del propio campo o la X de la lupa.
  void _toggleSearch(bool searchVisible) {
    final SearchVisibilityCubit cubit = context.read<SearchVisibilityCubit>();
    if (searchVisible) {
      cubit.hide();
    } else {
      cubit.show();
    }
  }

  /// Limpia la búsqueda de la sección visible y vuelve al contenido sin filtrar.
  void _clearSearch() {
    final _DashboardSection? section = _section;
    if (section == _DashboardSection.vod) {
      context.read<VodBloc>().add(const VodSearchChanged(''));
    } else if (section == _DashboardSection.series) {
      context.read<SeriesBloc>().add(const SeriesSearchChanged(''));
    } else if (section == _DashboardSection.live ||
        section == _DashboardSection.radio) {
      context.read<LiveBloc>().add(const LiveSearchChanged(''));
    }
    context.read<SearchVisibilityCubit>().hide();
  }

  /// Lupa con una X superpuesta: indica que el contenido está filtrado por una
  /// búsqueda activa y que pulsar la acción la limpia.
  Widget _buildSearchIcon() {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        const Icon(Icons.search),
        Positioned(
          right: -5,
          bottom: -5,
          child: Container(
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: scheme.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.close, size: 12, color: scheme.onPrimary),
          ),
        ),
      ],
    );
  }
}

/// Selector de secciones de la pantalla principal.
class _SectionsHome extends StatelessWidget {
  const _SectionsHome({required this.onSelected});

  final ValueChanged<_DashboardSection> onSelected;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final List<(_DashboardSection, IconData, String)> sections =
        <(_DashboardSection, IconData, String)>[
          (_DashboardSection.live, Icons.live_tv, l10n.liveTv),
          (_DashboardSection.vod, Icons.movie_outlined, l10n.movies),
          (_DashboardSection.series, Icons.theaters_outlined, l10n.series),
          (_DashboardSection.radio, Icons.radio, l10n.radio),
        ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = (constraints.maxWidth * 0.22).clamp(
          180.0,
          320.0,
        );
        // Centra el selector verticalmente en la pantalla (con margen para el
        // padding). En pantallas bajas el contenido sigue siendo desplazable.
        final double minHeight =
            constraints.hasBoundedHeight && constraints.maxHeight > 64
            ? constraints.maxHeight - 64
            : 0;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 24,
                    runSpacing: 24,
                    children: <Widget>[
                      for (int i = 0; i < sections.length; i++)
                        SizedBox(
                          width: cardWidth,
                          height: cardWidth * 0.78,
                          child: TvFocusable(
                            autofocus: i == 0,
                            borderRadius: BorderRadius.circular(18),
                            onPressed: () => onSelected(sections[i].$1),
                            child: Material(
                              color: context.colors.surface,
                              borderRadius: BorderRadius.circular(18),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                canRequestFocus: false,
                                onTap: () => onSelected(sections[i].$1),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      sections[i].$2,
                                      size: cardWidth * 0.28,
                                      color: context.colors.primary,
                                    ),
                                    const SizedBox(height: 12),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Text(
                                        sections[i].$3,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const ContinueWatchingRow(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Reloj de la barra superior, centrado.
///
/// Se actualiza al cambiar de minuto y respeta el formato 12/24 h de Ajustes.
/// No es interactivo (no captura el foco ni los toques del mando).
class _AppClock extends StatefulWidget {
  const _AppClock();

  @override
  State<_AppClock> createState() => _AppClockState();
}

class _AppClockState extends State<_AppClock> {
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _scheduleNextMinute();
  }

  /// Programa la actualización justo al inicio del siguiente minuto para no
  /// reconstruir el reloj cada segundo.
  void _scheduleNextMinute() {
    _timer?.cancel();
    final DateTime now = DateTime.now();
    final DateTime nextMinute = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    ).add(const Duration(minutes: 1));
    _timer = Timer(nextMinute.difference(now), () {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
      _scheduleNextMinute();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final bool clock24h = state is SettingsLoaded ? state.clock24h : true;
        final String time = formatClockTime(
          TimeOfDay.fromDateTime(_now),
          clock24h: clock24h,
          localizations: MaterialLocalizations.of(context),
        );
        final AppColors colors = context.colors;
        return IgnorePointer(
          child: SafeArea(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  time,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
