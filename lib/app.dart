import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_state.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/splash/splash_screen.dart';

/// Configuración de navegación de la aplicación.
abstract final class AppRouter {
  /// Listenable que re-evalúa los redirects cuando cambia el estado de auth.
  static GoRouter router(AuthBloc authBloc) {
    final GoRouterRefreshListenable refresh = GoRouterRefreshListenable(authBloc);

    return GoRouter(
      initialLocation: Routes.splash,
      refreshListenable: refresh,
      redirect: (context, state) {
        final AuthState auth = authBloc.state;
        return switch (auth) {
          AuthChecking() => Routes.splash,
          AuthUnauthenticated() || AuthFailure() => Routes.login,
          AuthAuthenticated() => state.matchedLocation == Routes.splash ||
                  state.matchedLocation == Routes.login
              ? Routes.dashboard
              : null,
        };
      },
      routes: <RouteBase>[
        GoRoute(path: Routes.splash, builder: (context, state) => const SplashScreen()),
        GoRoute(path: Routes.login, builder: (context, state) => const LoginScreen()),
        GoRoute(path: Routes.dashboard, builder: (context, state) => const DashboardScreen()),
      ],
    );
  }
}

/// Rutas declarativas de la aplicación.
abstract final class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
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
  const KyloraApp({super.key, required this.authBloc});

  final AuthBloc authBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => authBloc,
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
      ),
    );
  }
}
