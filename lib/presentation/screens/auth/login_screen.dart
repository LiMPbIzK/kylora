import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/iptv_auth_config.dart';
import '../../../domain/entities/iptv_source_type.dart';
import '../../../l10n/app_localizations.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';

/// Pantalla de inicio de sesión (Xtream o M3U/XMLTV).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.addAccount = false});

  /// Si es true, el formulario añade una cuenta a la lista en lugar de ser el
  /// login inicial de la aplicación.
  final bool addAccount;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  IptvSourceType _sourceType = IptvSourceType.xtream;

  // Campos Xtream.
  final TextEditingController _serverController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Campos M3U/XMLTV.
  final TextEditingController _playlistController = TextEditingController();
  final TextEditingController _xmltvController = TextEditingController();
  final TextEditingController _m3uNameController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _serverController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _playlistController.dispose();
    _xmltvController.dispose();
    _m3uNameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);

    final IptvAuthConfig config = switch (_sourceType) {
      IptvSourceType.xtream => XtreamAuthConfig(
        serverUrl: _serverController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      ),
      IptvSourceType.m3u => M3uAuthConfig(
        m3uUrl: _playlistController.text.trim(),
        xmltvUrl: _xmltvController.text.trim().isEmpty
            ? null
            : _xmltvController.text.trim(),
        displayName: _m3uNameController.text.trim().isEmpty
            ? null
            : _m3uNameController.text.trim(),
      ),
    };

    context.read<AuthBloc>().add(
      AuthLoginRequested(config, activate: !widget.addAccount),
    );
  }

  String? _urlValidator(String? value) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String? trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return l10n.validationRequired;
    }
    final Uri? uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return l10n.validationInvalidUrl;
    }
    return null;
  }

  String? _requiredValidator(String? value) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) return l10n.validationRequired;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool isM3u = _sourceType == IptvSourceType.m3u;

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (AuthState previous, AuthState current) =>
          _submitting &&
          (current is AuthAuthenticated || current is AuthFailure),
      listener: (BuildContext context, AuthState state) {
        if (state is AuthAuthenticated && widget.addAccount) {
          // Volver a la pantalla que abrió el formulario (Ajustes) para no
          // perder la pila de navegación ni el listener de cambio de cuenta.
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(Routes.settings);
          }
        } else if (state is AuthFailure && mounted) {
          setState(() => _submitting = false);
        }
      },
      child: Scaffold(
        appBar: widget.addAccount ? AppBar(title: Text(l10n.addAccount)) : null,
        // El teclado virtual (Android TV/móvil) no debe tapar los campos: el
        // body se redimensiona (inset) y se pide scroll para subir el activo.
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double bottomInset = MediaQuery.viewInsetsOf(context)
                  .bottom;
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 32,
                  bottom: bottomInset + 16,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - bottomInset,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: _LoginForm(
                        formKey: _formKey,
                        l10n: l10n,
                        isM3u: isM3u,
                        sourceType: _sourceType,
                        title: widget.addAccount
                            ? l10n.addAccount
                            : l10n.loginTitle,
                        buttonLabel: widget.addAccount
                            ? l10n.addAccount
                            : l10n.loginButton,
                        onSourceChanged: (IptvSourceType type) {
                          setState(() => _sourceType = type);
                        },
                        controllers: _LoginControllers(
                          server: _serverController,
                          username: _usernameController,
                          password: _passwordController,
                          playlist: _playlistController,
                          xmltv: _xmltvController,
                          m3uName: _m3uNameController,
                        ),
                        onFieldSubmitted: _submit,
                        onSubmitted: _submit,
                        urlValidator: _urlValidator,
                        requiredValidator: _requiredValidator,
                        onLoginWithPhone: widget.addAccount
                            ? null
                            : () => context.push(Routes.loginPhone),
                        onManageAccounts: widget.addAccount
                            ? null
                            : () => context.push(Routes.accounts),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Campos del formulario de login.
///
/// En Android TV el IME (teclado) NO redimensiona la ventana (no reporta
/// `viewInsets`), de modo que el campo activo puede quedar tapado. Este widget
/// crea el [FocusNode] del campo y, cuando recibe el foco, hace
/// `Scrollable.ensureVisible` para dejar el campo visible por encima del teclado.
class _AutoScrollField extends StatefulWidget {
  const _AutoScrollField({required this.builder});

  final Widget Function(FocusNode focusNode) builder;

  @override
  State<_AutoScrollField> createState() => _AutoScrollFieldState();
}

class _AutoScrollFieldState extends State<_AutoScrollField> {
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _fieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? ctx = _fieldKey.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        alignment: 0.3,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: _fieldKey, child: widget.builder(_focusNode));
  }
}

/// Controladores de texto del formulario de login.
class _LoginControllers {
  const _LoginControllers({
    required this.server,
    required this.username,
    required this.password,
    required this.playlist,
    required this.xmltv,
    required this.m3uName,
  });

  final TextEditingController server;
  final TextEditingController username;
  final TextEditingController password;
  final TextEditingController playlist;
  final TextEditingController xmltv;
  final TextEditingController m3uName;
}

/// Formulario de inicio de sesión.
class _LoginForm extends StatefulWidget {
  const _LoginForm({
    required this.formKey,
    required this.l10n,
    required this.isM3u,
    required this.sourceType,
    required this.onSourceChanged,
    required this.controllers,
    required this.title,
    required this.buttonLabel,
    required this.onFieldSubmitted,
    required this.onSubmitted,
    required this.urlValidator,
    required this.requiredValidator,
    this.onLoginWithPhone,
    this.onManageAccounts,
  });

  final GlobalKey<FormState> formKey;
  final AppLocalizations l10n;
  final bool isM3u;
  final IptvSourceType sourceType;
  final String title;
  final String buttonLabel;
  final ValueChanged<IptvSourceType> onSourceChanged;
  final _LoginControllers controllers;
  final VoidCallback onFieldSubmitted;
  final VoidCallback onSubmitted;
  final FormFieldValidator<String> urlValidator;
  final FormFieldValidator<String> requiredValidator;
  final VoidCallback? onLoginWithPhone;
  final VoidCallback? onManageAccounts;

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = widget.l10n;
    final _LoginControllers c = widget.controllers;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_resolveError(l10n, state.message))),
          );
        }
      },
      child: Form(
        key: widget.formKey,
        child: AutofillGroup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Icon(Icons.live_tv, size: 72, color: context.colors.primary),
              const SizedBox(height: 12),
              Text(
                'Kylora',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 32),
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
                selected: <IptvSourceType>{widget.sourceType},
                onSelectionChanged: (Set<IptvSourceType> selection) {
                  widget.onSourceChanged(selection.first);
                },
              ),
              const SizedBox(height: 24),
              if (widget.isM3u) ...<Widget>[
                _AutoScrollField(
                  builder: (FocusNode node) => TextFormField(
                    controller: c.m3uName,
                    focusNode: node,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.m3uDisplayName,
                      prefixIcon: const Icon(Icons.label_outline),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _AutoScrollField(
                  builder: (FocusNode node) => TextFormField(
                    controller: c.playlist,
                    focusNode: node,
                    autofillHints: const <String>[AutofillHints.url],
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.m3uPlaylistUrl,
                      prefixIcon: const Icon(Icons.link),
                    ),
                    validator: widget.urlValidator,
                  ),
                ),
                const SizedBox(height: 16),
                _AutoScrollField(
                  builder: (FocusNode node) => TextFormField(
                    controller: c.xmltv,
                    focusNode: node,
                    autofillHints: const <String>[AutofillHints.url],
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => widget.onFieldSubmitted(),
                    decoration: InputDecoration(
                      labelText: l10n.m3uXmltvUrl,
                      prefixIcon: const Icon(Icons.event_note),
                    ),
                  ),
                ),
              ] else ...<Widget>[
                _AutoScrollField(
                  builder: (FocusNode node) => TextFormField(
                    controller: c.server,
                    focusNode: node,
                    autofillHints: const <String>[AutofillHints.url],
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.serverUrl,
                      prefixIcon: const Icon(Icons.dns_outlined),
                    ),
                    validator: widget.urlValidator,
                  ),
                ),
                const SizedBox(height: 16),
                _AutoScrollField(
                  builder: (FocusNode node) => TextFormField(
                    controller: c.username,
                    focusNode: node,
                    autofillHints: const <String>[AutofillHints.username],
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.username,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    validator: widget.requiredValidator,
                  ),
                ),
                const SizedBox(height: 16),
                _AutoScrollField(
                  builder: (FocusNode node) => TextFormField(
                    controller: c.password,
                    focusNode: node,
                    autofillHints: const <String>[AutofillHints.password],
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => widget.onFieldSubmitted(),
                    decoration: InputDecoration(
                      labelText: l10n.password,
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                    validator: widget.requiredValidator,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              BlocBuilder<AuthBloc, AuthState>(
                buildWhen: (previous, current) => current is AuthChecking,
                builder: (context, state) {
                  final bool loading = state is AuthChecking;
                  return FilledButton(
                    onPressed: loading ? null : widget.onSubmitted,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(widget.buttonLabel),
                    ),
                  );
                },
              ),
              if (widget.onLoginWithPhone != null ||
                  widget.onManageAccounts != null) ...<Widget>[
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                if (widget.onLoginWithPhone != null)
                  OutlinedButton.icon(
                    onPressed: widget.onLoginWithPhone,
                    icon: const Icon(Icons.qr_code_2),
                    label: Text(l10n.loginWithPhone),
                  ),
                if (widget.onManageAccounts != null) ...<Widget>[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: widget.onManageAccounts,
                    icon: const Icon(Icons.manage_accounts_outlined),
                    label: Text(l10n.manageAccounts),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _resolveError(AppLocalizations l10n, String code) {
    return switch (code) {
      'invalidCredentials' => l10n.loginErrorInvalidCredentials,
      'networkError' => l10n.loginErrorNetwork,
      'm3uParseError' => l10n.loginErrorM3uParse,
      'accountExpired' => l10n.loginErrorAccountExpired,
      _ => l10n.loginErrorUnknown,
    };
  }
}
