import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/iptv_source_type.dart';
import '../../../domain/entities/saved_account.dart';
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // La información de la cuenta queda fija: el scroll empieza en las
          // acciones (Cambiar cuenta / Cerrar sesión).
          _SectionHeader(title: l10n.settingsSectionAccount),
          _accountInfoSection(context, l10n),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              // Padding inferior amplio para que todas las opciones (idiomas,
              // temas, soporte) puedan desplazarse por encima del borde en TV.
              padding: const EdgeInsets.only(bottom: 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _accountActions(context, l10n),
                  _SectionHeader(title: l10n.settingsSectionCatalog),
                  _catalogSection(context, l10n),
                  _SectionHeader(title: l10n.language),
                  _languageSection(context, l10n),
                  _SectionHeader(title: l10n.clock),
                  _clockSection(context, l10n),
                  _SectionHeader(title: l10n.settingsSectionAppearance),
                  _appearanceSection(context, l10n),
                  _SectionHeader(title: l10n.settingsSectionSecurity),
                  _securitySection(l10n),
                  _SectionHeader(title: l10n.settingsSectionSupport),
                  _supportSection(context, l10n),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Cuenta
  // ---------------------------------------------------------------------------

  Widget _accountInfoSection(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) => current is AuthAuthenticated,
      builder: (context, state) {
        if (state is! AuthAuthenticated) return const SizedBox.shrink();
        final UserAccount account = state.account;
        return _InfoGrid(
          children: account.sourceType == IptvSourceType.xtream
              ? _xtreamAccountRows(context, l10n, account)
              : _m3uAccountRows(context, l10n, account),
        );
      },
    );
  }

  Widget _accountActions(BuildContext context, AppLocalizations l10n) {
    final AppColors colors = context.colors;
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) => current is AuthAuthenticated,
      builder: (context, state) {
        final List<SavedAccount> accounts = state is AuthAuthenticated
            ? state.accounts
            : const <SavedAccount>[];
        final String? activeId = state is AuthAuthenticated
            ? state.activeAccountId
            : null;
        return Column(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.person_add_alt_1),
              title: Text(l10n.addAccount),
              onTap: () => context.push(Routes.accountAdd),
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_2),
              title: Text(l10n.addAccountFromPhone),
              onTap: () => context.push(Routes.accountWebImport),
            ),
            ListTile(
              leading: const Icon(Icons.switch_account),
              title: Text(l10n.changeAccount),
              onTap: () =>
                  _showAccountPicker(context, l10n, accounts, activeId),
            ),
            ListTile(
              leading: Icon(Icons.logout, color: colors.error),
              title: Text(l10n.signOut, style: TextStyle(color: colors.error)),
              onTap: () =>
                  context.read<AuthBloc>().add(const AuthLogoutRequested()),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAccountPicker(
    BuildContext context,
    AppLocalizations l10n,
    List<SavedAccount> accounts,
    String? activeId,
  ) async {
    if (accounts.isEmpty) return;
    final SavedAccount? selected = await showDialog<SavedAccount>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.selectAccount),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460, maxHeight: 420),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: accounts.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (BuildContext context, int index) {
                final SavedAccount account = accounts[index];
                final bool active = account.id == activeId;
                return ListTile(
                  autofocus: index == 0,
                  leading: Icon(
                    account.sourceType == IptvSourceType.xtream
                        ? Icons.dns_outlined
                        : Icons.playlist_play,
                  ),
                  title: Text(
                    account.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    account.serverUrl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: active
                      ? Icon(Icons.check_circle, color: context.colors.primary)
                      : null,
                  onTap: () => Navigator.of(dialogContext).pop(account),
                );
              },
            ),
          ),
        );
      },
    );

    if (selected == null || selected.id == activeId) return;
    if (!context.mounted) return;
    context.read<AuthBloc>().add(AuthAccountSwitchRequested(selected.id));
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
      _InfoTile(
        icon: Icons.link,
        label: l10n.m3uPlaylistUrl,
        value: playlistUrl,
      ),
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
        // ListTiles enfocables en lugar de RadioGroup/RadioListTile: en Android
        // TV los RadioGroup capturan Arriba/Abajo para cambiar la selección,
        // impidiendo navegar por la lista y dejando las opciones invisibles.
        return Column(
          children: <Widget>[
            _choiceTile(
              label: l10n.localeSystem,
              selected: currentCode == null,
              onTap: () => _setLocale(context, null),
            ),
            _choiceTile(
              label: l10n.languageSpanish,
              selected: currentCode == 'es',
              onTap: () => _setLocale(context, const Locale('es')),
            ),
            _choiceTile(
              label: l10n.languageEnglish,
              selected: currentCode == 'en',
              onTap: () => _setLocale(context, const Locale('en')),
            ),
            _choiceTile(
              label: l10n.languageFrench,
              selected: currentCode == 'fr',
              onTap: () => _setLocale(context, const Locale('fr')),
            ),
            _choiceTile(
              label: l10n.languageGerman,
              selected: currentCode == 'de',
              onTap: () => _setLocale(context, const Locale('de')),
            ),
            _choiceTile(
              label: l10n.languageItalian,
              selected: currentCode == 'it',
              onTap: () => _setLocale(context, const Locale('it')),
            ),
            _choiceTile(
              label: l10n.languagePortuguese,
              selected: currentCode == 'pt',
              onTap: () => _setLocale(context, const Locale('pt')),
            ),
          ],
        );
      },
    );
  }

  void _setLocale(BuildContext context, Locale? locale) {
    context.read<SettingsBloc>().add(SettingsLocaleChanged(locale));
  }

  // ---------------------------------------------------------------------------
  // Reloj
  // ---------------------------------------------------------------------------

  Widget _clockSection(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (previous, current) => current is SettingsLoaded,
      builder: (context, state) {
        final bool clock24h = state is SettingsLoaded ? state.clock24h : true;
        return Column(
          children: <Widget>[
            _choiceTile(
              label: l10n.clockFormat24h,
              selected: clock24h,
              onTap: () => context.read<SettingsBloc>().add(
                const SettingsClockFormatChanged(true),
              ),
            ),
            _choiceTile(
              label: l10n.clockFormat12h,
              selected: !clock24h,
              onTap: () => context.read<SettingsBloc>().add(
                const SettingsClockFormatChanged(false),
              ),
            ),
          ],
        );
      },
    );
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
        // Igual que en el idioma: filas enfocables para que el D-Pad navegue
        // en lugar de que RadioGroup cambie la selección con las flechas.
        return Column(
          children: <Widget>[
            for (final MapEntry<String, ThemeData> entry in AppThemes.entries)
              _choiceTile(
                label: _themeLabel(l10n, entry.key),
                selected: entry.key == currentId,
                onTap: () => _setTheme(context, entry.key),
              ),
          ],
        );
      },
    );
  }

  /// Fila seleccionable (idioma, tema…) con icono de radio y navegación por
  /// D-Pad normal: enfocar no cambia la selección; hay que pulsar OK.
  Widget _choiceTile({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final AppColors colors = context.colors;
    return ListTile(
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: selected ? colors.secondary : colors.onSurfaceVariant,
      ),
      title: Text(label),
      selected: selected,
      onTap: onTap,
    );
  }

  String _themeLabel(AppLocalizations l10n, String id) {
    return switch (id) {
      AppThemes.nocturne => l10n.themeNocturne,
      AppThemes.expressive => l10n.themeExpressive,
      AppThemes.pacotis => l10n.themePacotis,
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

  // ---------------------------------------------------------------------------
  // Soporte
  // ---------------------------------------------------------------------------

  static const String _donationUrl = 'https://paypal.me/franito';
  static const String _contactEmail = 'contact@fmartinezgarcia.com';
  static const String _contactSubject = 'Kylora';

  Widget _supportSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.favorite, color: context.colors.secondary),
          title: Text(l10n.donation),
          subtitle: Text(l10n.donationDescription),
          onTap: () => _openDonation(l10n),
        ),
        ListTile(
          leading: const Icon(Icons.mail_outline),
          title: Text(l10n.contact),
          subtitle: Text(l10n.contactDescription),
          onTap: () => _openContact(l10n),
        ),
      ],
    );
  }

  Future<void> _openDonation(AppLocalizations l10n) async {
    final Uri uri = Uri.parse(_donationUrl);
    final bool opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      _showSnack(context, l10n.donationOpenError);
    }
  }

  Future<void> _openContact(AppLocalizations l10n) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: _contactEmail,
      queryParameters: <String, String>{'subject': _contactSubject},
    );
    final bool opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      _showSnack(context, l10n.contactOpenError);
    }
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

/// Rejilla compacta para los datos de la cuenta (no enfocables).
///
/// En TV/escritorio se muestran varios campos por fila para no desperdiciar
/// espacio vertical; la última fila queda centrada (sin hueco a la derecha).
class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surfaceVariant.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(12),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // En pantallas anchas (TV) los datos van en una sola fila compacta;
            // en pantallas estrechas se reparten en 3/2 columnas centradas.
            final bool singleRow = constraints.maxWidth >= 1100;
            if (singleRow) {
              return Row(
                children: <Widget>[
                  for (int i = 0; i < children.length; i++) ...<Widget>[
                    if (i > 0)
                      Container(
                        width: 1,
                        height: 34,
                        margin: const EdgeInsets.symmetric(horizontal: 14),
                        color: colors.onSurfaceVariant.withValues(alpha: 0.18),
                      ),
                    Expanded(child: children[i]),
                  ],
                ],
              );
            }
            final int columns = constraints.maxWidth >= 700 ? 3 : 2;
            const double spacing = 12;
            final double tileWidth =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;
            return Wrap(
              alignment: WrapAlignment.center,
              spacing: spacing,
              runSpacing: 12,
              children: <Widget>[
                for (final Widget child in children)
                  SizedBox(width: tileWidth, child: child),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Dato compacto etiqueta/valor de la cuenta (sin tarjeta propia).
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(icon, size: 13, color: colors.onSurfaceVariant),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13.5,
            height: 1.2,
            fontWeight: FontWeight.w500,
            color: valueColor ?? colors.onSurface,
          ),
        ),
      ],
    );
  }
}
