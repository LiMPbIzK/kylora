import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../live/live_screen.dart';
import '../series/series_screen.dart';
import '../vod/vod_screen.dart';

/// Pantalla principal autenticada con pestañas superiores para cambiar
/// entre Directo, Películas y Series.
class HomeShellScreen extends StatelessWidget {
  const HomeShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
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
          bottom: TabBar(
            indicatorColor: context.colors.primary,
            labelColor: context.colors.onSurface,
            unselectedLabelColor: context.colors.onSurface,
            tabs: <Widget>[
              Tab(text: l10n.liveTv, icon: const Icon(Icons.live_tv, size: 20)),
              Tab(text: l10n.movies, icon: const Icon(Icons.movie, size: 20)),
              Tab(text: l10n.series, icon: const Icon(Icons.theaters, size: 20)),
            ],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            LiveScreen(),
            VodScreen(),
            SeriesScreen(),
          ],
        ),
      ),
    );
  }
}
