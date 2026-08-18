import 'package:flutter/foundation.dart';

/// Constantes globales de la aplicación.
abstract final class AppConstants {
  /// Endpoint de autenticación de la API Xtream Codes.
  static const String xtreamAuthPath = 'player_api.php';

  /// Clave del campo `user_info` en la respuesta de autenticación.
  static const String xtreamUserInfoKey = 'user_info';

  /// Cabecera `User-Agent` identificativa del cliente.
  static String get userAgent => kDebugMode ? 'Kylora/1.0 (debug)' : 'Kylora/1.0';
}

/// Timeouts de red centralizados.
abstract final class AppTimeouts {
  static const Duration connect = Duration(seconds: 15);
  static const Duration receive = Duration(seconds: 30);
}
