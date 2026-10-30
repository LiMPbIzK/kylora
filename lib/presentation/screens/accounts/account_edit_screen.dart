import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/local/auth_store.dart';
import '../../../domain/entities/iptv_source_type.dart';
import '../../../l10n/app_localizations.dart';
import '../../blocs/auth/auth_bloc.dart';

/// Alta o edición de credenciales sin validarlas contra el proveedor.
///
/// Es imprescindible para cuentas caducadas: se guardan para poder corregirlas
/// o sustituirlas aunque el login falle.
class AccountEditScreen extends StatefulWidget {
  const AccountEditScreen({super.key, this.account});

  final StoredAccount? account;

  @override
  State<AccountEditScreen> createState() => _AccountEditScreenState();
}

class _AccountEditScreenState extends State<AccountEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late IptvSourceType _sourceType;
  late final TextEditingController _labelController;
  late final TextEditingController _serverController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _m3uController;
  late final TextEditingController _xmltvController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final StoredAccount? account = widget.account;
    _sourceType = account?.credentials.sourceType ?? IptvSourceType.xtream;
    _labelController = TextEditingController(text: account?.label ?? '');
    _serverController = TextEditingController(
      text: account?.credentials.sourceType == IptvSourceType.xtream
          ? account?.credentials.serverUrl ?? ''
          : '',
    );
    _usernameController = TextEditingController(
      text: account?.credentials.sourceType == IptvSourceType.xtream
          ? account?.credentials.username ?? ''
          : '',
    );
    _passwordController = TextEditingController();
    _m3uController = TextEditingController(
      text: account?.credentials.sourceType == IptvSourceType.m3u
          ? account?.credentials.m3uUrl ?? account?.credentials.serverUrl ?? ''
          : '',
    );
    _xmltvController = TextEditingController(
      text: account?.credentials.xmltvUrl ?? '',
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    _serverController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _m3uController.dispose();
    _xmltvController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final AccountStore? store = context.read<AuthBloc>().accountStore;
    if (store == null) {
      setState(() => _saving = false);
      return;
    }

    final StoredCredentials credentials = _sourceType == IptvSourceType.m3u
        ? StoredCredentials(
            serverUrl: _m3uController.text.trim(),
            username: '',
            password: '',
            sourceType: IptvSourceType.m3u,
            m3uUrl: _m3uController.text.trim(),
            xmltvUrl: _xmltvController.text.trim().isEmpty
                ? null
                : _xmltvController.text.trim(),
          )
        : StoredCredentials(
            serverUrl: _serverController.text.trim(),
            username: _usernameController.text.trim(),
            password: _passwordController.text.isEmpty
                ? widget.account?.credentials.password ?? ''
                : _passwordController.text,
            sourceType: IptvSourceType.xtream,
          );
    final String label = _labelController.text.trim();
    try {
      if (widget.account == null) {
        await store.write(
          credentials,
          label: label.isEmpty ? null : label,
          activate: false,
        );
      } else {
        await store.replace(
          widget.account!.id,
          credentials,
          label: label.isEmpty ? null : label,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.saveError)),
      );
    }
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.validationRequired;
    }
    return null;
  }

  String? _url(String? value) {
    final String? required = _required(value);
    if (required != null) return required;
    final Uri? uri = Uri.tryParse(value!.trim());
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return AppLocalizations.of(context)!.validationInvalidUrl;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool editing = widget.account != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? l10n.accountEdit : l10n.addAccount),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            SegmentedButton<IptvSourceType>(
              segments: <ButtonSegment<IptvSourceType>>[
                ButtonSegment<IptvSourceType>(
                  value: IptvSourceType.xtream,
                  label: Text(l10n.loginSourceXtream),
                  icon: const Icon(Icons.dns_outlined),
                ),
                ButtonSegment<IptvSourceType>(
                  value: IptvSourceType.m3u,
                  label: Text(l10n.loginSourceM3u),
                  icon: const Icon(Icons.playlist_play),
                ),
              ],
              selected: <IptvSourceType>{_sourceType},
              onSelectionChanged: (Set<IptvSourceType> selection) {
                setState(() => _sourceType = selection.first);
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _labelController,
              decoration: InputDecoration(
                labelText: l10n.accountLabel,
                prefixIcon: const Icon(Icons.label_outline),
              ),
            ),
            const SizedBox(height: 14),
            if (_sourceType == IptvSourceType.xtream) ...<Widget>[
              TextFormField(
                controller: _serverController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: l10n.serverUrl,
                  prefixIcon: const Icon(Icons.dns_outlined),
                ),
                validator: _url,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: l10n.username,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: _required,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.password,
                  helperText: editing ? l10n.passwordKeepHint : null,
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                validator: (String? value) {
                  if (editing && (value == null || value.isEmpty)) {
                    return null;
                  }
                  return _required(value);
                },
              ),
            ] else ...<Widget>[
              TextFormField(
                controller: _m3uController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: l10n.m3uPlaylistUrl,
                  prefixIcon: const Icon(Icons.link),
                ),
                validator: _url,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _xmltvController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: l10n.m3uXmltvUrl,
                  prefixIcon: const Icon(Icons.event_note),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Text(
              l10n.accountSavePendingHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save),
              label: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
