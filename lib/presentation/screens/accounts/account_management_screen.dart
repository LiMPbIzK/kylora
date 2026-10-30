import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/datasources/local/auth_store.dart';
import '../../../data/datasources/local/pin_service.dart';
import '../../../domain/entities/iptv_auth_config.dart';
import '../../../domain/entities/iptv_source_type.dart';
import '../../../domain/entities/user_account.dart';
import '../../../domain/repositories/iptv_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';

/// Gestión de cuentas guardadas sin depender de una sesión válida.
///
/// Es la salida de emergencia cuando todas las cuentas están caducadas: la
/// lista se lee de `AuthStore`, no del proveedor, y permite editar, añadir o
/// reintentar el login.
class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key, this.pinService});

  final PinService? pinService;

  @override
  State<AccountManagementScreen> createState() =>
      _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  late final PinService _pinService = widget.pinService ?? PinService();
  final TextEditingController _pinController = TextEditingController();
  bool _checkingPin = true;
  bool _locked = false;
  String? _pinError;
  bool _loading = true;
  String? _error;
  List<StoredAccount> _accounts = <StoredAccount>[];
  String? _activeId;
  String? _busyId;

  @override
  void initState() {
    super.initState();
    _checkPin();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _checkPin() async {
    final bool enabled = await _pinService.isEnabled();
    if (!mounted) return;
    if (!enabled) {
      setState(() => _checkingPin = false);
      await _load();
      return;
    }
    setState(() {
      _checkingPin = false;
      _locked = true;
    });
  }

  Future<void> _unlock() async {
    final bool valid = await _pinService.verify(_pinController.text);
    if (!mounted) return;
    if (!valid) {
      setState(() => _pinError = AppLocalizations.of(context)!.pinWrong);
      return;
    }
    PinService.markSessionUnlocked();
    setState(() {
      _locked = false;
      _pinError = null;
    });
    await _load();
  }

  Future<void> _load() async {
    final AccountStore? store = context.read<AuthBloc>().accountStore;
    if (store == null) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = AppLocalizations.of(context)!.loginErrorUnknown;
      });
      return;
    }
    try {
      final List<StoredAccount> accounts = await store.readAll();
      final String? activeId = await store.readActiveId();
      if (!mounted) return;
      setState(() {
        _accounts = accounts;
        _activeId = activeId;
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = AppLocalizations.of(context)!.loginErrorUnknown;
      });
    }
  }

  Future<void> _login(StoredAccount stored) async {
    if (_busyId != null) return;
    setState(() => _busyId = stored.id);
    final IptvRepository repository = context.read<IptvRepository>();
    final AccountStore store = context.read<AuthBloc>().accountStore!;
    try {
      final IptvAuthConfig config = _configFor(stored);
      final UserAccount account = await repository.login(
        config,
        activate: true,
      );
      await store.updateMetadata(
        stored.id,
        lastStatus: account.status,
        expiresAt: account.expiresAt,
        lastCheckedAt: DateTime.now(),
      );
      if (!mounted) return;
      if (!account.isActive || account.isExpired) {
        setState(() => _busyId = null);
        _showMessage(AppLocalizations.of(context)!.loginErrorAccountExpired);
        await _load();
        return;
      }
      context.read<AuthBloc>().add(AuthExternalLoginSucceeded(account));
      context.go(Routes.dashboard);
    } catch (_) {
      if (!mounted) return;
      setState(() => _busyId = null);
      _showMessage(AppLocalizations.of(context)!.loginErrorUnknown);
    }
  }

  IptvAuthConfig _configFor(StoredAccount account) {
    final StoredCredentials credentials = account.credentials;
    if (credentials.sourceType == IptvSourceType.m3u) {
      return M3uAuthConfig(
        m3uUrl: credentials.m3uUrl ?? credentials.serverUrl,
        xmltvUrl: credentials.xmltvUrl,
        displayName: account.label,
      );
    }
    return XtreamAuthConfig(
      serverUrl: credentials.serverUrl,
      username: credentials.username,
      password: credentials.password,
    );
  }

  Future<void> _addAccount() async {
    final bool? changed = await context.push<bool>(Routes.accountEdit);
    if (changed == true && mounted) await _load();
  }

  Future<void> _editAccount(StoredAccount account) async {
    final bool? changed = await context.push<bool>(
      Routes.accountEdit,
      extra: account,
    );
    if (changed == true && mounted) await _load();
  }

  Future<void> _openPhoneImport() async {
    await context.push(Routes.accountWebImport);
    if (mounted) await _load();
  }

  Future<void> _cleanExpired() async {
    final List<StoredAccount> expired = _accounts
        .where(
          (StoredAccount account) =>
              account.id != _activeId && _isExpired(account),
        )
        .toList();
    if (expired.isEmpty) return;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.cleanExpiredAccounts),
        content: Text(AppLocalizations.of(context)!.cleanExpiredConfirm),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.accountDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final AccountStore? store = context.read<AuthBloc>().accountStore;
    for (final StoredAccount account in expired) {
      await store?.remove(account.id);
    }
    if (!mounted) return;
    await _load();
    if (!mounted) return;
    _showMessage(AppLocalizations.of(context)!.expiredAccountsRemoved);
  }

  Future<void> _deleteAccount(StoredAccount account) async {
    if (account.id == _activeId) {
      _showMessage(AppLocalizations.of(context)!.accountActive);
      return;
    }
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.accountDelete),
        content: Text(AppLocalizations.of(context)!.deleteAccountConfirm),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.accountDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final AccountStore? store = context.read<AuthBloc>().accountStore;
    await store?.remove(account.id);
    if (mounted) await _load();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageAccounts),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.addAccount,
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: _addAccount,
          ),
        ],
      ),
      body: _checkingPin
          ? const Center(child: CircularProgressIndicator())
          : _locked
          ? _lockedBody(l10n)
          : _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _accounts.isEmpty
          ? _emptyState(l10n)
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: <Widget>[
                Text(
                  l10n.accountManagerDescription,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: context.colors.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                for (final StoredAccount account in _accounts)
                  _buildAccountCard(context, l10n, account),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: <Widget>[
                    FilledButton.tonalIcon(
                      onPressed: _addAccount,
                      icon: const Icon(Icons.add),
                      label: Text(l10n.addAccount),
                    ),
                    OutlinedButton.icon(
                      onPressed: _openPhoneImport,
                      icon: const Icon(Icons.qr_code_2),
                      label: Text(l10n.addAccountFromPhone),
                    ),
                    if (_accounts.any(
                      (StoredAccount account) =>
                          account.id != _activeId && _isExpired(account),
                    ))
                      TextButton.icon(
                        onPressed: _cleanExpired,
                        icon: const Icon(Icons.auto_delete_outlined),
                        label: Text(l10n.cleanExpiredAccounts),
                      ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _lockedBody(AppLocalizations l10n) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.lock_outline, size: 56, color: context.colors.primary),
              const SizedBox(height: 16),
              Text(
                l10n.pinProtectAccounts,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.pinEnter,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.colors.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _pinController,
                autofocus: true,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 8,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: l10n.pinCode,
                  errorText: _pinError,
                  counterText: '',
                ),
                onSubmitted: (_) => _unlock(),
              ),
              const SizedBox(height: 12),
              FilledButton(onPressed: _unlock, child: Text(l10n.unlock)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.person_off_outlined,
            size: 56,
            color: context.colors.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(l10n.noSavedAccounts),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _addAccount,
            icon: const Icon(Icons.person_add_alt_1),
            label: Text(l10n.addAccount),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _openPhoneImport,
            icon: const Icon(Icons.qr_code_2),
            label: Text(l10n.addAccountFromPhone),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(
    BuildContext context,
    AppLocalizations l10n,
    StoredAccount account,
  ) {
    final bool active = account.id == _activeId;
    final bool expired = _isExpired(account);
    final String status = account.lastStatus == null
        ? l10n.accountNotValidated
        : expired
        ? l10n.accountExpired
        : l10n.accountActive;
    final String checked = account.lastCheckedAt == null
        ? ''
        : ' · ${DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).add_Hm().format(account.lastCheckedAt!)}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => _login(account),
        leading: Icon(
          account.credentials.sourceType == IptvSourceType.xtream
              ? Icons.dns_outlined
              : Icons.playlist_play,
        ),
        title: Text(
          account.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${account.credentials.sourceUrl}\n'
          '${account.credentials.username.isEmpty ? '—' : account.credentials.username}'
          ' · $status$checked',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: _busyId == account.id
            ? const SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (active)
                    Icon(Icons.check_circle, color: context.colors.primary),
                  IconButton(
                    tooltip: l10n.accountEdit,
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _editAccount(account),
                  ),
                  IconButton(
                    tooltip: l10n.accountDelete,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _deleteAccount(account),
                  ),
                ],
              ),
      ),
    );
  }

  bool _isExpired(StoredAccount account) {
    final String status = (account.lastStatus ?? '').toLowerCase();
    if (status.isNotEmpty && status != 'active') return true;
    return account.expiresAt != null &&
        account.expiresAt!.isBefore(DateTime.now());
  }
}
