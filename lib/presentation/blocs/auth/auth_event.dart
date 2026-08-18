import 'package:equatable/equatable.dart';

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

/// Intenta iniciar sesión con credenciales nuevas.
final class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({
    required this.serverUrl,
    required this.username,
    required this.password,
  });

  final String serverUrl;
  final String username;
  final String password;

  @override
  List<Object?> get props => [serverUrl, username, password];
}

/// Cierra la sesión activa.
final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
