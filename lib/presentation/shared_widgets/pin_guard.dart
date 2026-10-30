import 'package:flutter/material.dart';

import '../../data/datasources/local/pin_service.dart';
import '../../l10n/app_localizations.dart';

/// Protege una pantalla de cuentas con el PIN opcional.
///
/// La comprobación se hace una vez por sesión: al desbloquear el gestor de
/// cuentas, las pantallas de edición/QR abiertas desde él no vuelven a pedirlo.
class PinGuard extends StatefulWidget {
  const PinGuard({super.key, required this.child, this.pinService});

  final Widget child;
  final PinService? pinService;

  @override
  State<PinGuard> createState() => _PinGuardState();
}

class _PinGuardState extends State<PinGuard> {
  late final PinService _pinService = widget.pinService ?? PinService();
  final TextEditingController _controller = TextEditingController();
  bool _loading = true;
  bool _locked = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _check();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    final bool enabled = await _pinService.isEnabled();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _locked = enabled && !PinService.isSessionUnlocked;
    });
  }

  Future<void> _unlock() async {
    final bool valid = await _pinService.verify(_controller.text);
    if (!mounted) return;
    if (!valid) {
      setState(() => _error = AppLocalizations.of(context)!.pinWrong);
      return;
    }
    PinService.markSessionUnlocked();
    setState(() {
      _locked = false;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!_locked) return widget.child;
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.pinProtectAccounts)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.lock_outline, size: 56),
                const SizedBox(height: 16),
                Text(l10n.pinEnter, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 8,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: l10n.pinCode,
                    errorText: _error,
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
      ),
    );
  }
}
