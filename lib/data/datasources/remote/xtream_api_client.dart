import 'package:dio/dio.dart';

import '../../../core/constants/app_constants.dart';
import '../../models/xtream_user_info_dto.dart';

/// Respuesta de autenticación Xtream Codes.
class XtreamAuthResponse {
  const XtreamAuthResponse({required this.userInfo, this.serverInfo});

  final XtreamUserInfoDto userInfo;
  final Map<String, dynamic>? serverInfo;

  factory XtreamAuthResponse.fromJson(Map<String, dynamic> json) {
    final dynamic rawUser = json[AppConstants.xtreamUserInfoKey];
    if (rawUser is! Map<String, dynamic>) {
      throw const FormatException('Respuesta de autenticación inválida');
    }
    return XtreamAuthResponse(
      userInfo: XtreamUserInfoDto.fromJson(rawUser),
      serverInfo: json['server_info'] as Map<String, dynamic>?,
    );
  }
}

/// Cliente HTTP para la API Xtream Codes (solo `player_api.php`).
class XtreamApiClient {
  XtreamApiClient(Dio dio) : _dio = dio;

  final Dio _dio;

  /// Autentica contra el servidor Xtream.
  ///
  /// Lanza [XtreamAuthException] cuando el servidor responde sin `user_info`
  /// (credenciales o URL inválidas).
  Future<XtreamAuthResponse> authenticate({
    required String serverUrl,
    required String username,
    required String password,
  }) async {
    final Uri uri = Uri.parse(serverUrl).resolve(
      '${AppConstants.xtreamAuthPath}'
      '?username=${Uri.encodeQueryComponent(username)}'
      '&password=${Uri.encodeQueryComponent(password)}',
    );

    try {
      final Response<dynamic> response = await _dio.get<dynamic>(uri.toString());
      if (response.statusCode != 200) {
        throw XtreamAuthException('HTTP ${response.statusCode}');
      }
      final dynamic data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Respuesta de autenticación inválida');
      }
      return XtreamAuthResponse.fromJson(data);
    } on DioException catch (e) {
      throw XtreamNetworkException(e.message ?? 'Fallo de red', cause: e);
    }
  }
}

/// Error de autenticación Xtream (credenciales o URL inválidas).
class XtreamAuthException implements Exception {
  const XtreamAuthException(this.message);

  final String message;

  @override
  String toString() => 'XtreamAuthException: $message';
}

/// Error de red contra el servidor Xtream.
class XtreamNetworkException implements Exception {
  const XtreamNetworkException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'XtreamNetworkException: $message';
}
