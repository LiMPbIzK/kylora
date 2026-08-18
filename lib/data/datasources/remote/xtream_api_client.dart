import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/constants/app_constants.dart';
import '../../models/xtream_category_dto.dart';
import '../../models/xtream_series_dto.dart';
import '../../models/xtream_series_info_dto.dart';
import '../../models/xtream_stream_dto.dart';
import '../../models/xtream_user_info_dto.dart';
import '../../models/xtream_vod_stream_dto.dart';

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
      final Response<dynamic> response = await _dio.get<dynamic>(
        uri.toString(),
      );
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

  /// Obtiene las categorías de canales en directo.
  Future<List<XtreamCategoryDto>> fetchLiveCategories({
    required String serverUrl,
    required String username,
    required String password,
  }) async {
    final List<dynamic> data = await _getList(
      serverUrl: serverUrl,
      username: username,
      password: password,
      action: 'get_live_categories',
    ) as List<dynamic>;
    return data
        .map<XtreamCategoryDto>(
          (dynamic item) =>
              XtreamCategoryDto.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  /// Obtiene los canales en directo, opcionalmente filtrados por categoría.
  Future<List<XtreamStreamDto>> fetchLiveStreams({
    required String serverUrl,
    required String username,
    required String password,
    int? categoryId,
  }) async {
    final List<dynamic> data = await _getList(
      serverUrl: serverUrl,
      username: username,
      password: password,
      action: 'get_live_streams',
      extra: <String, String>{
        if (categoryId != null) 'category_id': '$categoryId',
      },
    ) as List<dynamic>;
    return data
        .map<XtreamStreamDto>(
          (dynamic item) =>
              XtreamStreamDto.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  /// Obtiene las categorías de películas (VOD).
  Future<List<XtreamCategoryDto>> fetchVodCategories({
    required String serverUrl,
    required String username,
    required String password,
  }) async {
    final List<dynamic> data = await _getList(
      serverUrl: serverUrl,
      username: username,
      password: password,
      action: 'get_vod_categories',
    ) as List<dynamic>;
    return data
        .map<XtreamCategoryDto>(
          (dynamic item) =>
              XtreamCategoryDto.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  /// Obtiene las películas (VOD), opcionalmente filtradas por categoría.
  Future<List<XtreamVodStreamDto>> fetchVodStreams({
    required String serverUrl,
    required String username,
    required String password,
    int? categoryId,
  }) async {
    final List<dynamic> data = await _getList(
      serverUrl: serverUrl,
      username: username,
      password: password,
      action: 'get_vod_streams',
      extra: <String, String>{
        if (categoryId != null) 'category_id': '$categoryId',
      },
    ) as List<dynamic>;
    return data
        .map<XtreamVodStreamDto>(
          (dynamic item) =>
              XtreamVodStreamDto.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  /// Obtiene las categorías de series.
  Future<List<XtreamCategoryDto>> fetchSeriesCategories({
    required String serverUrl,
    required String username,
    required String password,
  }) async {
    final List<dynamic> data = await _getList(
      serverUrl: serverUrl,
      username: username,
      password: password,
      action: 'get_series_categories',
    ) as List<dynamic>;
    return data
        .map<XtreamCategoryDto>(
          (dynamic item) =>
              XtreamCategoryDto.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  /// Obtiene las series, opcionalmente filtradas por categoría.
  Future<List<XtreamSeriesDto>> fetchSeries({
    required String serverUrl,
    required String username,
    required String password,
    int? categoryId,
  }) async {
    final List<dynamic> data = await _getList(
      serverUrl: serverUrl,
      username: username,
      password: password,
      action: 'get_series',
      extra: <String, String>{
        if (categoryId != null) 'category_id': '$categoryId',
      },
    ) as List<dynamic>;
    return data
        .map<XtreamSeriesDto>(
          (dynamic item) =>
              XtreamSeriesDto.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  /// Obtiene la información detallada de una serie con sus temporadas.
  Future<XtreamSeriesInfoDto> fetchSeriesInfo({
    required String serverUrl,
    required String username,
    required String password,
    required int seriesId,
  }) async {
    final Uri uri = Uri.parse(serverUrl).resolve(
      '${AppConstants.xtreamAuthPath}'
      '?username=${Uri.encodeQueryComponent(username)}'
      '&password=${Uri.encodeQueryComponent(password)}'
      '&action=get_series_info'
      '&series_id=$seriesId',
    );
    try {
      final Response<dynamic> response = await _dio.get<dynamic>(uri.toString());
      if (response.statusCode != 200) {
        throw XtreamNetworkException('HTTP ${response.statusCode}');
      }
      final dynamic data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Respuesta de info de serie inválida');
      }
      return XtreamSeriesInfoDto.fromJson(data);
    } on DioException catch (e) {
      throw XtreamNetworkException(e.message ?? 'Fallo de red', cause: e);
    }
  }

  /// GET genérico a `player_api.php` que devuelve una lista JSON.
  Future<dynamic> _getList({
    required String serverUrl,
    required String username,
    required String password,
    required String action,
    Map<String, String> extra = const <String, String>{},
  }) async {
    final Uri uri = Uri.parse(serverUrl).resolve(
      '${AppConstants.xtreamAuthPath}'
      '?username=${Uri.encodeQueryComponent(username)}'
      '&password=${Uri.encodeQueryComponent(password)}'
      '&action=$action'
      '${extra.entries.map((entry) => '&${entry.key}=${Uri.encodeQueryComponent(entry.value)}').join()}',
    );
    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        uri.toString(),
      );
      if (kDebugMode) {
        debugPrint('XAPI[$action] status=${response.statusCode} '
            'dataType=${response.data.runtimeType} '
            'dataLen=${response.data is List ? (response.data as List).length : -1}');
      }
      if (response.statusCode != 200) {
        throw XtreamNetworkException('HTTP ${response.statusCode}');
      }
      final dynamic data = response.data;
      if (data is! List<dynamic>) {
        throw FormatException(
          'Respuesta de lista inválida para $action: ${data.runtimeType}',
        );
      }
      return data;
    } on DioException catch (e) {
      throw XtreamNetworkException(
        'DioException($action) type=${e.type} msg=${e.message} '
        'status=${e.response?.statusCode}',
        cause: e,
      );
    } on TypeError catch (e) {
      throw XtreamNetworkException('TypeError($action) ${e.toString()}', cause: e);
    } on FormatException catch (e) {
      throw XtreamNetworkException('FormatException($action) ${e.toString()}', cause: e);
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
