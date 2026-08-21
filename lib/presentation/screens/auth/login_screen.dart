import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/iptv_auth_config.dart';
import '../../../domain/entities/iptv_source_type.dart';
import '../../../l10n/app_localizations.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';

/// Pantalla de inicio de sesión (Xtream o M3U/XMLTV).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

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
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

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

    context.read<AuthBloc>().add(AuthLoginRequested(config));
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

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_localizeError(l10n, state.message)),
                      ),
                    );
                  }
                },
                child: Form(
                  key: _formKey,
                  child: AutofillGroup(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const Icon(
                          Icons.live_tv,
                          size: 72,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Kylora',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.loginTitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.onSurface.withValues(
                                  alpha: 0.7,
                                ),
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
                          selected: <IptvSourceType>{_sourceType},
                          onSelectionChanged: (Set<IptvSourceType> selection) {
                            setState(() => _sourceType = selection.first);
                          },
                        ),
                        const SizedBox(height: 24),
                        if (isM3u) ...<Widget>[
                          TextFormField(
                            controller: _m3uNameController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: l10n.m3uDisplayName,
                              prefixIcon: const Icon(Icons.label_outline),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _playlistController,
                            autofillHints: const <String>[AutofillHints.url],
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: l10n.m3uPlaylistUrl,
                              prefixIcon: const Icon(Icons.link),
                            ),
                            validator: _urlValidator,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _xmltvController,
                            autofillHints: const <String>[AutofillHints.url],
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            decoration: InputDecoration(
                              labelText: l10n.m3uXmltvUrl,
                              prefixIcon: const Icon(Icons.event_note),
                            ),
                          ),
                        ] else ...<Widget>[
                          TextFormField(
                            controller: _serverController,
                            autofillHints: const <String>[AutofillHints.url],
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: l10n.serverUrl,
                              prefixIcon: const Icon(Icons.dns_outlined),
                            ),
                            validator: _urlValidator,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _usernameController,
                            autofillHints: const <String>[
                              AutofillHints.username,
                            ],
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: l10n.username,
                              prefixIcon: const Icon(Icons.person_outline),
                            ),
                            validator: _requiredValidator,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            autofillHints: const <String>[
                              AutofillHints.password,
                            ],
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            decoration: InputDecoration(
                              labelText: l10n.password,
                              prefixIcon: const Icon(Icons.lock_outline),
                            ),
                            validator: _requiredValidator,
                          ),
                        ],
                        const SizedBox(height: 24),
                        BlocBuilder<AuthBloc, AuthState>(
                          buildWhen: (previous, current) =>
                              current is AuthChecking,
                          builder: (context, state) {
                            final bool loading = state is AuthChecking;
                            return FilledButton(
                              onPressed: loading ? null : _submit,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: loading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(l10n.loginButton),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _localizeError(AppLocalizations l10n, String code) {
    return switch (code) {
      'invalidCredentials' => l10n.loginErrorInvalidCredentials,
      'networkError' => l10n.loginErrorNetwork,
      'm3uParseError' => l10n.loginErrorM3uParse,
      _ => l10n.loginErrorUnknown,
    };
  }
}
