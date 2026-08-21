import 'package:equatable/equatable.dart';

import 'iptv_source_type.dart';

/// Parámetros polimórficos para iniciar sesión en una fuente IPTV.
///
/// Unifica el contrato de `IptvRepository.login()` y los eventos de `AuthBloc`
/// sin depender de un tipo de fuente concreto.
sealed class IptvAuthConfig extends Equatable {
  const IptvAuthConfig();

  IptvSourceType get sourceType;

  @override
  List<Object?> get props => [sourceType];
}

/// Parámetros para la API Xtream Codes.
final class XtreamAuthConfig extends IptvAuthConfig {
  const XtreamAuthConfig({
    required this.serverUrl,
    required this.username,
    required this.password,
  });

  final String serverUrl;
  final String username;
  final String password;

  @override
  IptvSourceType get sourceType => IptvSourceType.xtream;

  @override
  List<Object?> get props => [sourceType, serverUrl, username, password];
}

/// Parámetros para una fuente M3U/XMLTV.
final class M3uAuthConfig extends IptvAuthConfig {
  const M3uAuthConfig({
    required this.m3uUrl,
    this.xmltvUrl,
    this.displayName,
  });

  /// URL de la lista M3U (remota o local con esquema file://).
  final String m3uUrl;

  /// URL opcional de la guía EPG en formato XMLTV.
  final String? xmltvUrl;

  /// Nombre descriptivo de la fuente (para mostrar en la UI).
  final String? displayName;

  @override
  IptvSourceType get sourceType => IptvSourceType.m3u;

  @override
  List<Object?> get props => [sourceType, m3uUrl, xmltvUrl, displayName];
}
