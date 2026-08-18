import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

/// Menú principal: Directo, VOD, Series, Favoritos y Ajustes.
/// En M0 es la pantalla vacía que aloja la navegación por secciones.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n!.appTitle),
      ),
      body: const Center(
        child: Icon(
          Icons.live_tv,
          size: 96,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
