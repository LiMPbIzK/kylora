import 'package:equatable/equatable.dart';

import 'iptv_source_type.dart';

/// Resumen de una cuenta guardada, apto para la UI y para el estado de Auth.
///
/// No contiene la contraseña: esa permanece únicamente en el almacenamiento
/// seguro y se consulta a través de `AuthStore`.
class SavedAccount extends Equatable {
  const SavedAccount({
    required this.id,
    required this.label,
    required this.sourceType,
    required this.serverUrl,
    required this.username,
    this.lastStatus,
    this.expiresAt,
    this.lastCheckedAt,
  });

  final String id;
  final String label;
  final IptvSourceType sourceType;
  final String serverUrl;
  final String username;

  /// Último estado devuelto por el proveedor (`Active`, `Expired`...).
  final String? lastStatus;

  /// Caducidad conocida de la cuenta, si el proveedor la informó.
  final DateTime? expiresAt;

  /// Última comprobación contra el proveedor.
  final DateTime? lastCheckedAt;

  bool get isExpired {
    final String status = (lastStatus ?? '').toLowerCase();
    if (status.isNotEmpty && status != 'active') return true;
    return expiresAt != null && expiresAt!.isBefore(DateTime.now());
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    label,
    sourceType,
    serverUrl,
    username,
    lastStatus,
    expiresAt,
    lastCheckedAt,
  ];
}
