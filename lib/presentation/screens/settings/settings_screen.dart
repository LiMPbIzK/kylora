import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/iptv_source_type.dart';
import '../../../domain/entities/user_account.dart';
import '../../../domain/repositories/iptv_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/live/live_bloc.dart';
import '../../blocs/live/live_event.dart';
import '../../blocs/series/series_bloc.dart';
import '../../blocs/series/series_event.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../blocs/settings/settings_event.dart';
import '../../blocs/settings/settings_state.dart';
import '../../blocs/vod/vod_bloc.dart';
import '../../blocs/vod/vod_event.dart';

/// Pantalla de ajustes de la aplicación.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _refreshing = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: <Widget>[
          _SectionHeader(title: l10n.settingsSectionAccount),
          _accountSection(context, l10n),
          _SectionHeader(title: l10n.settingsSectionCatalog),
          _catalogSection(context, l10n),
          _SectionHeader(title: l10n.language),
          _languageSection(context, l10n),
          _SectionHeader(title: l10n.settingsSectionAppearance),
          _appearanceSection(context, l10n),
          _SectionHeader(title: l10n.settingsSectionSecurity),
          _securitySection(l10n),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Cuenta
  // ---------------------------------------------------------------------------

  Widget _accountSection(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) => current is AuthAuthenticated,
      builder: (context, state) {
        if (state is! AuthAuthenticated) return const SizedBox.shrink();
        final UserAccount account = state.account;
        final AppColors colors = context.colors;

        return Column(
          children: <Widget>[
            if (account.sourceType == IptvSourceType.xtream)
              ..._xtreamAccountRows(context, l10n, account)
            else
              ..._m3uAccountRows(context, l10n, account),
            const Divider(height: 24),
            ListTile(
              leading: const Icon(Icons.switch_account),
              title: Text(l10n.changeAccount),
              onTap: () => context
                  .read<AuthBloc>()
                  .add(const AuthLogoutRequested()),
            ),
            ListTile(
              leading: Icon(Icons.logout, color: colors.error),
              title: Text(
                l10n.signOut,
                style: TextStyle(color: colors.error),
              ),
              onTap: () => context
                  .read<AuthBloc>()
                  .add(const AuthLogoutRequested()),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _xtreamAccountRows(
    BuildContext context,
    AppLocalizations l10n,
    UserAccount account,
  ) {
    final String date = account.expiresAt == null
        ? '—'
        : DateFormat.yMMMd().format(account.expiresAt!);
    final String connections = account.maxConnections == null
        ? '—'
        : l10n.accountConnections(
            '${account.activeConnections ?? 0}',
            '${account.maxConnections}',
          );

    return <Widget>[
      _InfoTile(
        icon: Icons.dns_outlined,
        label: l10n.serverUrl,
        value: account.serverUrl,
      ),
      _InfoTile(
        icon: Icons.person_outline,
        label: l10n.username,
        value: account.username,
      ),
      _InfoTile(
        icon: Icons.verified_user_outlined,
        label: l10n.accountStatus,
        value: account.isActive ? l10n.accountActive : l10n.accountExpired,
        valueColor: account.isActive
          ? context.colors.secondary
          : context.colors.error,
      ),
      _InfoTile(
        icon: Icons.event_outlined,
        label: l10n.accountExpiration,
        value: date,
      ),
      if (account.maxConnections != null)
        _InfoTile(
          icon: Icons.connected_tv_outlined,
          label: l10n.accountConnectionsLabel,
          value: connections,
        ),
    ];
  }

  List<Widget> _m3uAccountRows(
    BuildContext context,
    AppLocalizations l10n,
    UserAccount account,
  ) {
    final String playlistUrl = account.username.isEmpty
        ? account.serverUrl
        : account.username;
    return <Widget>[
      _InfoTile(
        icon: Icons.playlist_play,
        label: l10n.accountSource,
        value: l10n.loginSourceM3u,
      ),
      _InfoTile(icon: Icons.link, label: l10n.m3uPlaylistUrl, value: playlistUrl),
      _InfoTile(
        icon: Icons.event_note,
        label: l10n.m3uXmltvUrl,
        value: (account.xmltvUrl?.isNotEmpty ?? false)
            ? l10n.accountXmltvPresent
            : l10n.accountXmltvMissing,
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Catálogo
  // ---------------------------------------------------------------------------

  Widget _catalogSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: <Widget>[
        ListTile(
          leading: _refreshing
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh),
          title: Text(l10n.refreshCatalog),
          subtitle: Text(l10n.refreshCatalogDescription),
          enabled: !_refreshing,
          onTap: _refreshing ? null : () => _refreshCatalog(l10n),
        ),
        ListTile(
          leading: const Icon(Icons.cleaning_services_outlined),
          title: Text(l10n.clearCache),
          onTap: () => _clearCache(l10n),
        ),
      ],
    );
  }

  Future<void> _refreshCatalog(AppLocalizations l10n) async {
    final IptvRepository repository = context.read<IptvRepository>();
    final LiveBloc liveBloc = context.read<LiveBloc>();
    final VodBloc vodBloc = context.read<VodBloc>();
    final SeriesBloc seriesBloc = context.read<SeriesBloc>();
    setState(() => _refreshing = true);
    try {
      await repository.refreshCatalog();
      liveBloc.add(const LiveRefreshRequested());
      vodBloc.add(const VodRefreshRequested());
      seriesBloc.add(const SeriesRefreshRequested());
      if (mounted) _showSnack(context, l10n.refreshCatalogSuccess);
    } catch (_) {
      if (mounted) _showSnack(context, l10n.refreshCatalogFailure);
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  Future<void> _clearCache(AppLocalizations l10n) async {
    final IptvRepository repository = context.read<IptvRepository>();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.clearCache),
        content: Text(l10n.clearCacheConfirm),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.clearCache),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await repository.clearCatalogCache();
      if (mounted) _showSnack(context, l10n.clearCacheSuccess);
    }
  }

  // ---------------------------------------------------------------------------
  // Idioma
  // ---------------------------------------------------------------------------

  Widget _languageSection(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (previous, current) => current is SettingsLoaded,
      builder: (context, state) {
        final String? currentCode = state is SettingsLoaded
            ? state.locale?.languageCode
            : null;
        return RadioGroup<String?>(
          groupValue: currentCode,
          onChanged: (String? code) => _setLocale(
            context,
            code == null ? null : Locale(code),
          ),
          child: Column(
            children: <Widget>[
              RadioListTile<String?>(
                value: null,
                title: Text(l10n.localeSystem),
              ),
              RadioListTile<String?>(
                value: 'es',
                title: Text(l10n.languageSpanish),
              ),
              RadioListTile<String?>(
                value: 'en',
                title: Text(l10n.languageEnglish),
              ),
              RadioListTile<String?>(
                value: 'fr',
                title: Text(l10n.languageFrench),
              ),
              RadioListTile<String?>(
                value: 'de',
                title: Text(l10n.languageGerman),
              ),
              RadioListTile<String?>(
                value: 'it',
                title: Text(l10n.languageItalian),
              ),
              RadioListTile<String?>(
                value: 'pt',
                title: Text(l10n.languagePortuguese),
              ),
            ],
          ),
        );
      },
    );
  }

  void _setLocale(BuildContext context, Locale? locale) {
    context.read<SettingsBloc>().add(SettingsLocaleChanged(locale));
  }

  // ---------------------------------------------------------------------------
  // Apariencia
  // ---------------------------------------------------------------------------

  Widget _appearanceSection(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (previous, current) => current is SettingsLoaded,
      builder: (context, state) {
        final String currentId = state is SettingsLoaded
            ? state.themeId
            : AppThemes.nocturne;
        return RadioGroup<String>(
          groupValue: currentId,
          onChanged: (String? id) {
            if (id != null) _setTheme(context, id);
          },
          child: Column(
            children: <Widget>[
              for (final MapEntry<String, ThemeData> entry in AppThemes.entries)
                RadioListTile<String>(
                  value: entry.key,
                  title: Text(_themeLabel(l10n, entry.key)),
                ),
            ],
          ),
        );
      },
    );
  }

  String _themeLabel(AppLocalizations l10n, String id) {
    return switch (id) {
      AppThemes.nocturne => l10n.themeNocturne,
      AppThemes.expressive => l10n.themeExpressive,
      AppThemes.aurora => l10n.themeAurora,
      AppThemes.canvas => l10n.themeCanvas,
      _ => id,
    };
  }

  void _setTheme(BuildContext context, String themeId) {
    context.read<SettingsBloc>().add(SettingsThemeChanged(themeId));
  }

  // ---------------------------------------------------------------------------
  // Seguridad
  // ---------------------------------------------------------------------------

  Widget _securitySection(AppLocalizations l10n) {
    return ListTile(
      enabled: false,
      leading: const Icon(Icons.lock_outline),
      title: Text(l10n.pinCode),
      subtitle: Text(l10n.comingSoon),
      trailing: const Switch(value: false, onChanged: null),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Encabezado de sección de los ajustes.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: context.colors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Fila de información etiqueta/valor.
class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return ListTile(
      dense: true,
      leading: Icon(icon, color: colors.onSurfaceVariant),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: colors.onSurfaceVariant,
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(color: valueColor ?? colors.onSurface),
      ),
    );
  }
}