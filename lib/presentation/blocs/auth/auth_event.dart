import 'package:equatable/equatable.dart';

import '../../../domain/entities/iptv_auth_config.dart';
import '../../../domain/entities/user_account.dart';

/// Eventos del flujo de autenticación.
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Restaura la sesión guardada al arrancar la aplicación.
final class AuthStarted extends AuthEvent {
  const AuthStarted();
}

/// Intenta iniciar sesión con una configuración de fuente determinada.
final class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested(this.config, {this.activate = true});

  final IptvAuthConfig config;

  /// Si es false, la cuenta se guarda pero la activa no cambia.
  final bool activate;

  @override
  List<Object?> get props => <Object?>[config, activate];
}

/// Cierra la sesión activa (las cuentas guardadas se conservan).
final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Cambia la cuenta activa sin borrar las demás.
final class AuthAccountSwitchRequested extends AuthEvent {
  const AuthAccountSwitchRequested(this.accountId);

  final String accountId;

  @override
  List<Object?> get props => <Object?>[accountId];
}

/// Sesión iniciada desde un canal externo (por ejemplo, el acceso remoto por
/// QR). El repositorio ya ha persistido y activado las credenciales.
final class AuthExternalLoginSucceeded extends AuthEvent {
  const AuthExternalLoginSucceeded(this.account);

  final UserAccount account;

  @override
  List<Object?> get props => <Object?>[account];
}

/// Vuelve a leer la lista de cuentas guardadas sin cambiar la activa.
///
/// Lo usa la importación web después de añadir, renombrar o borrar una cuenta.
final class AuthAccountsReloadRequested extends AuthEvent {
  const AuthAccountsReloadRequested();
}
