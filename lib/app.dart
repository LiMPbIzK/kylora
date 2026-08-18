import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/media/playback_controller.dart';
import 'core/theme/app_theme.dart';
import 'domain/entities/movie.dart';
import 'domain/entities/series.dart';
import 'domain/repositories/iptv_repository.dart';
import 'l10n/app_localizations.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_state.dart';
import 'presentation/blocs/live/live_bloc.dart';
import 'presentation/blocs/series/series_bloc.dart';
import 'presentation/blocs/vod/vod_bloc.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/dashboard/home_shell_screen.dart';
import 'presentation/screens/player/playback_overlay.dart';
import 'presentation/screens/player/playback_scope.dart';
import 'presentation/screens/series/series_detail_screen.dart';
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
        return switch (auth) {
          AuthChecking() => Routes.splash,
          AuthUnauthenticated() || AuthFailure() => Routes.login,
          AuthAuthenticated() =>
            state.matchedLocation == Routes.splash ||
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
    required this.repository,
    required this.playbackController,
  });

  final AuthBloc authBloc;
  final LiveBloc liveBloc;
  final VodBloc vodBloc;
  final SeriesBloc seriesBloc;
  final IptvRepository repository;
  final PlaybackController playbackController;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<StateStreamableSource<Object?>>>[
        BlocProvider<AuthBloc>(create: (_) => authBloc),
        BlocProvider<LiveBloc>(create: (_) => liveBloc),
        BlocProvider<VodBloc>(create: (_) => vodBloc),
        BlocProvider<SeriesBloc>(create: (_) => seriesBloc),
      ],
      child: RepositoryProvider<IptvRepository>.value(
        value: repository,
        child: PlaybackScope(
          controller: playbackController,
          child: MaterialApp.router(
            title: 'Kylora',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark,
            routerConfig: AppRouter.router(authBloc),
            localizationsDelegates: const <LocalizationsDelegate<Object>>[
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            localeResolutionCallback:
                (Locale? locale, Iterable<Locale> supportedLocales) {
                  // Detección automática del sistema; el usuario podrá cambiarlo en M9.
                  return null;
                },
            builder: (context, child) => PlaybackOverlay(
              controller: playbackController,
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}
