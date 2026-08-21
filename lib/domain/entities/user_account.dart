import 'package:equatable/equatable.dart';

import 'iptv_source_type.dart';

/// Cuenta de usuario obtenida del proveedor IPTV.
class UserAccount extends Equatable {
  const UserAccount({
    required this.serverUrl,
    required this.username,
    required this.password,
    required this.status,
    this.sourceType = IptvSourceType.xtream,
    this.expiresAt,
    this.maxConnections,
    this.activeConnections,
  });

  final String serverUrl;
  final String username;
  final String password;
  final String status;

  /// Tipo de fuente con la que se inició la sesión.
  final IptvSourceType sourceType;
  final DateTime? expiresAt;
  final int? maxConnections;
  final int? activeConnections;

  bool get isActive => status.toLowerCase() == 'active';

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  @override
  List<Object?> get props => [
    serverUrl,
    username,
    password,
    status,
    sourceType,
    expiresAt,
    maxConnections,
    activeConnections,
  ];
}
