import 'package:equatable/equatable.dart';

import '../../../domain/entities/iptv_auth_config.dart';

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
  const AuthLoginRequested(this.config);

  final IptvAuthConfig config;

  @override
  List<Object?> get props => [config];
}

/// Cierra la sesión activa.
final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
