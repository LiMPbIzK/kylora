import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/media/playback_controller.dart';
import 'core/theme/app_theme.dart';
import 'domain/entities/channel.dart';
import 'domain/entities/movie.dart';
import 'domain/entities/series.dart';
import 'domain/repositories/iptv_repository.dart';
import 'l10n/app_localizations.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_state.dart';
import 'presentation/blocs/epg/epg_bloc.dart';
import 'presentation/blocs/favorites/favorites_bloc.dart';
import 'presentation/blocs/history/history_bloc.dart';
import 'presentation/blocs/live/live_bloc.dart';
import 'presentation/blocs/series/series_bloc.dart';
import 'presentation/blocs/settings/settings_bloc.dart';
import 'presentation/blocs/settings/settings_state.dart';
import 'presentation/blocs/search/search_visibility_cubit.dart';
import 'presentation/blocs/vod/vod_bloc.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/dashboard/home_shell_screen.dart';
import 'presentation/screens/favorites/favorites_screen.dart';
import 'presentation/screens/history/history_screen.dart';
import 'presentation/screens/live/program_guide_screen.dart';
import 'presentation/screens/player/playback_overlay.dart';
import 'presentation/screens/player/playback_scope.dart';
import 'presentation/screens/series/series_detail_screen.dart';
import 'presentation/screens/settings/account_web_import_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/vod/movie_detail_screen.dart';

/// Configuración de navegación de la aplicación.
abstract final class AppRouter {
  /// Listenable que re-evalúa los redirects cuando cambia el estado de auth.
  static GoRouter router(AuthBloc authBloc) {
    final GoRouterRefreshListenable refresh = GoRouterRefreshListenable(
      authBloc,
    );

    return GoRouter(
      initialLocation: Routes.splash,
      refreshListenable: refresh,
      redirect: (context, state) {
        final AuthState auth = authBloc.state;
        final bool addingAccount = state.matchedLocation == Routes.accountAdd;
        return switch (auth) {
          AuthChecking() => addingAccount ? null : Routes.splash,
          AuthUnauthenticated() ||
          AuthFailure() => addingAccount ? null : Routes.login,
          AuthAuthenticated() =>
            addingAccount
                ? null
                : state.matchedLocation == Routes.splash ||
                      state.matchedLocation == Routes.login
                ? Routes.dashboard
                : null,
        };
      },
      routes: <RouteBase>[
        GoRoute(
          path: Routes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: Routes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: Routes.dashboard,
          builder: (context, state) => const HomeShellScreen(),
        ),
        GoRoute(
          path: Routes.movieDetail,
          builder: (context, state) =>
              MovieDetailScreen(movie: state.extra! as Movie),
        ),
        GoRoute(
          path: Routes.seriesDetail,
          builder: (context, state) {
            final Series series = state.extra! as Series;
            return SeriesDetailScreen(series: series);
          },
        ),
        GoRoute(
          path: Routes.programGuide,
          builder: (context, state) {
            final Channel channel = state.extra! as Channel;
            return ProgramGuideScreen(channel: channel);
          },
        ),
        GoRoute(
          path: Routes.favorites,
          builder: (context, state) => const FavoritesScreen(),
        ),
        GoRoute(
          path: Routes.history,
          builder: (context, state) => const HistoryScreen(),
        ),
        GoRoute(
          path: Routes.settings,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: Routes.accountAdd,
          builder: (context, state) => const LoginScreen(addAccount: true),
        ),
        GoRoute(
          path: Routes.accountWebImport,
          builder: (context, state) => const AccountWebImportScreen(),
        ),
      ],
    );
  }
}

/// Rutas declarativas de la aplicación.
abstract final class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String movieDetail = '/movie';
  static const String seriesDetail = '/series-detail';
  static const String programGuide = '/program-guide';
  static const String favorites = '/favorites';
  static const String history = '/history';
  static const String settings = '/settings';
  static const String accountAdd = '/account-add';
  static const String accountWebImport = '/account-import';
}

/// Adapta el stream del bloc a un [Listenable] para `go_router`.
class GoRouterRefreshListenable extends ChangeNotifier {
  GoRouterRefreshListenable(AuthBloc bloc) {
    _subscription = bloc.stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Raíz de la aplicación: configura idioma, tema y router.
class KyloraApp extends StatelessWidget {
  const KyloraApp({
    super.key,
    required this.authBloc,
    required this.liveBloc,
    required this.vodBloc,
    required this.seriesBloc,
    required this.epgBloc,
    required this.favoritesBloc,
    required this.historyBloc,
    required this.settingsBloc,
    required this.repository,
    required this.playbackController,
  });

  final AuthBloc authBloc;
  final LiveBloc liveBloc;
  final VodBloc vodBloc;
  final SeriesBloc seriesBloc;
  final EpgBloc epgBloc;
  final FavoritesBloc favoritesBloc;
  final HistoryBloc historyBloc;
  final SettingsBloc settingsBloc;
  final IptvRepository repository;
  final PlaybackController playbackController;

  @override
  Widget build(BuildContext context) {
    // El router se crea UNA sola vez aquí (no dentro del BlocBuilder de
    // Ajustes): así cambiar idioma o tema no reconstruye el GoRouter, que de lo
    // contrario reiniciaría en la ruta inicial y "cerraría" la pantalla actual
    // (p. ej. los Ajustes al seleccionar idioma) volviendo al dashboard.
    final GoRouter router = AppRouter.router(authBloc);

    return MultiBlocProvider(
      providers: <BlocProvider<StateStreamableSource<Object?>>>[
        BlocProvider<AuthBloc>(create: (_) => authBloc),
        BlocProvider<LiveBloc>(create: (_) => liveBloc),
        BlocProvider<VodBloc>(create: (_) => vodBloc),
        BlocProvider<SeriesBloc>(create: (_) => seriesBloc),
        BlocProvider<EpgBloc>(create: (_) => epgBloc),
        BlocProvider<FavoritesBloc>(create: (_) => favoritesBloc),
        BlocProvider<HistoryBloc>(create: (_) => historyBloc),
        BlocProvider<SettingsBloc>(create: (_) => settingsBloc),
        BlocProvider<SearchVisibilityCubit>(
          create: (_) => SearchVisibilityCubit(),
        ),
      ],
      child: RepositoryProvider<IptvRepository>.value(
        value: repository,
        child: PlaybackScope(
          controller: playbackController,
          child: BlocBuilder<SettingsBloc, SettingsState>(
            buildWhen: (previous, current) => previous != current,
            builder: (context, settings) {
              final Locale? locale = settings is SettingsLoaded
                  ? settings.locale
                  : null;
              final ThemeData theme = settings is SettingsLoaded
                  ? AppThemes.byId(settings.themeId)
                  : AppTheme.nocturne;
              return MaterialApp.router(
                title: 'Kylora',
                debugShowCheckedModeBanner: false,
                theme: theme,
                routerConfig: router,
                localizationsDelegates: const <LocalizationsDelegate<Object>>[
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: AppLocalizations.supportedLocales,
                locale: locale,
                localeResolutionCallback:
                    (Locale? systemLocale, Iterable<Locale> supported) {
                      // Si el usuario eligió un idioma manualmente, se respeta tal
                      // cual (ya viene en `locale` y Flutter lo aplica).
                      if (locale != null) return locale;
                      // Sin idioma manual: resuelve el idioma del sistema.
                      // Match por código de idioma (Android TV suele reportar
                      // es_ES/es_419/etc.), con español como respaldo.
                      if (systemLocale == null) return const Locale('es');
                      final String code = systemLocale.languageCode;
                      for (final Locale candidate in supported) {
                        if (candidate.languageCode == code) return candidate;
                      }
                      return const Locale('es');
                    },
                builder: (context, child) {
                  // Navegación direccional (TV/mando): los sliders solo capturan
                  // Izquierda/Derecha para cambiar el valor; Arriba/Abajo siguen
                  // moviendo el foco fuera de ellos (sin quedar atrapado en la
                  // barra de volumen o de progreso).
                  final MediaQueryData media = MediaQuery.of(context);
                  return MediaQuery(
                    data: media.copyWith(
                      navigationMode: NavigationMode.directional,
                    ),
                    child: PlaybackOverlay(
                      controller: playbackController,
                      child: child ?? const SizedBox.shrink(),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
