import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/user_account.dart';
import '../../../l10n/app_localizations.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../../app.dart';

/// Menú principal: Directo, VOD, Series, Favoritos y Ajustes.
/// Muestra el estado de cuenta y permite cerrar sesión.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kylora'),
        actions: <Widget>[
          BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (previous, current) => current is AuthAuthenticated,
            builder: (context, state) {
              if (state is! AuthAuthenticated) return const SizedBox.shrink();
              return IconButton(
                tooltip: l10n.signOut,
                icon: const Icon(Icons.logout),
                onPressed: () =>
                    context.read<AuthBloc>().add(const AuthLogoutRequested()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.live_tv, size: 96, color: AppColors.primary),
            const SizedBox(height: 16),
            BlocBuilder<AuthBloc, AuthState>(
              buildWhen: (previous, current) => current is AuthAuthenticated,
              builder: (context, state) {
                if (state is! AuthAuthenticated) return const SizedBox.shrink();
                return _AccountCard(account: state.account);
              },
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: <Widget>[
                FilledButton.icon(
                  icon: const Icon(Icons.live_tv),
                  label: Text(l10n.liveTv),
                  onPressed: () => context.go(Routes.live),
                ),
                FilledButton.tonalIcon(
                  icon: const Icon(Icons.movie),
                  label: Text(l10n.movies),
                  onPressed: () => context.go(Routes.vod),
                ),
                FilledButton.tonalIcon(
                  icon: const Icon(Icons.theaters),
                  label: Text(l10n.series),
                  onPressed: () => context.go(Routes.series),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta con el estado de la cuenta (expiración y conexiones).
class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.account});

  final UserAccount account;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final DateFormat dateFormat = DateFormat.yMMMMd(
      Localizations.localeOf(context).toString(),
    );

    final String statusText = account.isActive
        ? l10n.accountActive
        : l10n.accountExpired;
    final Color statusColor = account.isActive
        ? AppColors.secondary
        : AppColors.error;
    final String? expiresText = account.expiresAt != null
        ? l10n.accountExpiresOn(dateFormat.format(account.expiresAt!))
        : null;
    final String? connectionsText =
        (account.maxConnections != null && account.activeConnections != null)
        ? l10n.accountConnections(
            '${account.activeConnections}',
            '${account.maxConnections}',
          )
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              account.username,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              account.serverUrl,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.circle, size: 10, color: statusColor),
                const SizedBox(width: 8),
                Text(
                  l10n.accountStatus,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (expiresText != null) ...[
              const SizedBox(height: 8),
              Text(expiresText, style: Theme.of(context).textTheme.bodyMedium),
            ],
            if (connectionsText != null) ...[
              const SizedBox(height: 8),
              Text(
                connectionsText,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
