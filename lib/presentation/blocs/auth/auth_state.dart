import 'package:equatable/equatable.dart';

import '../../../domain/entities/user_account.dart';

/// Estado del flujo de autenticación.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Comprobando sesión guardada al arrancar.
final class AuthChecking extends AuthState {
  const AuthChecking();
}

/// Sin sesión activa; se muestra la pantalla de login.
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Sesión activa y cuenta cargada.
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.account});

  final UserAccount account;

  @override
  List<Object?> get props => [account];
}

/// Fallo de autenticación con mensaje informativo.
final class AuthFailure extends AuthState {
  const AuthFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
