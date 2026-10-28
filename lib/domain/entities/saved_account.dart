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
  });

  final String id;
  final String label;
  final IptvSourceType sourceType;
  final String serverUrl;
  final String username;

  @override
  List<Object?> get props => <Object?>[
    id,
    label,
    sourceType,
    serverUrl,
    username,
  ];
}
