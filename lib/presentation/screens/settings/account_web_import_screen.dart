import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/datasources/local/auth_store.dart';
import '../../../data/datasources/local/local_account_server.dart';
import '../../../domain/entities/user_account.dart';
import '../../../domain/repositories/iptv_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';

/// Alta y gestión de cuentas desde el móvil mediante un servidor HTTP local.
///
/// El servidor solo está activo mientras esta pantalla está montada.
class AccountWebImportScreen extends StatefulWidget {
  const AccountWebImportScreen({super.key, this.remoteLogin = false});

  /// Si es true, esta pantalla es el acceso remoto desde el login: al
  /// autenticar una cuenta desde el móvil se entra directamente al dashboard.
  final bool remoteLogin;

  @override
  State<AccountWebImportScreen> createState() => _AccountWebImportScreenState();
}

class _AccountWebImportScreenState extends State<AccountWebImportScreen> {
  LocalAccountServer? _server;
  String? _url;
  String? _error;
  bool _starting = true;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _start();
  }

  Future<void> _start() async {
    _server?.stop();
    if (mounted) {
      setState(() {
        _starting = true;
        _url = null;
        _error = null;
      });
    }

    final AuthBloc authBloc = context.read<AuthBloc>();
    final AccountStore? accountStore = authBloc.accountStore;
    if (accountStore == null) {
      if (mounted) {
        setState(() {
          _starting = false;
          _error = AppLocalizations.of(context)!.webImportError;
        });
      }
      return;
    }

    final LocalAccountServer server = LocalAccountServer(
      repository: context.read<IptvRepository>(),
      accountStore: accountStore,
      onAccountsChanged: () {
        if (mounted) {
          authBloc.add(const AuthAccountsReloadRequested());
        }
      },
      onAuthenticated: (UserAccount account) {
        if (!mounted) return;
        authBloc.add(AuthExternalLoginSucceeded(account));
      },
    );

    try {
      final String url = await server.start();
      if (!mounted) {
        await server.stop();
        return;
      }
      setState(() {
        _server = server;
        _url = url;
        _starting = false;
      });
    } catch (_) {
      await server.stop();
      if (mounted) {
        setState(() {
          _starting = false;
          _error = AppLocalizations.of(context)!.webImportError;
        });
      }
    }
  }

  @override
  void dispose() {
    _server?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AppColors colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.remoteLogin ? l10n.remoteLoginTitle : l10n.addAccountFromPhone,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: _starting
                  ? Column(
                      children: <Widget>[
                        CircularProgressIndicator(color: colors.primary),
                        const SizedBox(height: 16),
                        Text(l10n.webImportStarting),
                      ],
                    )
                  : _error != null
                  ? Column(
                      children: <Widget>[
                        Icon(
                          Icons.wifi_off,
                          size: 56,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          onPressed: _start,
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.retry),
                        ),
                      ],
                    )
                  : Column(
                      children: <Widget>[
                        Text(
                          widget.remoteLogin
                              ? l10n.remoteLoginInstructions
                              : l10n.webImportInstructions,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: QrImageView(
                            data: _url!,
                            version: QrVersions.auto,
                            size: 260,
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 18),
                        SelectableText(
                          _url!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontFamily: 'monospace',
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                Icons.info_outline,
                                color: colors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  l10n.webImportLocalOnly,
                                  style: TextStyle(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
