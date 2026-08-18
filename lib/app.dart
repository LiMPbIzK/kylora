import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';

/// Configuración de navegación de la aplicación.
abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: Routes.dashboard,
    routes: <RouteBase>[
      GoRoute(
        path: Routes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
  );
}

/// Rutas declarativas de la aplicación.
abstract final class Routes {
  static const String dashboard = '/dashboard';
}

/// Raíz de la aplicación: configura idioma, tema y router.
class KyloraApp extends StatelessWidget {
  const KyloraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kylora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: AppRouter.router,
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
    );
  }
}
