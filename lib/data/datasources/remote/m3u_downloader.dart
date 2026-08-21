import 'dart:io';

import 'package:dio/dio.dart';

/// Error de red al descargar una fuente M3U/XMLTV.
class M3uNetworkException implements Exception {
  const M3uNetworkException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'M3uNetworkException: $message';
}

/// Error de parseo del contenido M3U/XMLTV.
class M3uParseException implements Exception {
  const M3uParseException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'M3uParseException: $message';
}

/// Descarga y lectura de listas M3U y guías XMLTV, locales o remotas.
class M3uDownloader {
  M3uDownloader(this._dio);

  final Dio _dio;

  /// Descarga el contenido de una lista M3U/XMLTV.
  ///
  /// Soporta URLs `http(s)://` y rutas locales con esquema `file://`.
  /// [userAgent] permite enviar una cabecera específica al servidor.
  Future<String> download(String url, {String? userAgent}) async {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      throw M3uNetworkException('URL inválida: $url');
    }

    if (uri.scheme == 'file') {
      return _readLocalFile(uri.path);
    }

    if (uri.scheme != 'http' && uri.scheme != 'https') {
      throw M3uNetworkException('Esquema no soportado: ${uri.scheme}');
    }

    try {
      final Response<String> response = await _dio.get<String>(
        uri.toString(),
        options: Options(
          responseType: ResponseType.plain,
          headers: <String, dynamic>{
            if (userAgent != null && userAgent.isNotEmpty)
              'User-Agent': userAgent,
          },
        ),
      );
      if (response.statusCode != 200) {
        throw M3uNetworkException('HTTP ${response.statusCode} al descargar $url');
      }
      return response.data ?? '';
    } on DioException catch (e) {
      throw M3uNetworkException(e.message ?? 'Fallo de red', cause: e);
    }
  }

  Future<String> _readLocalFile(String path) async {
    try {
      final File file = File(path);
      if (!await file.exists()) {
        throw M3uNetworkException('Fichero no encontrado: $path');
      }
      return await file.readAsString();
    } on IOException catch (e) {
      throw M3uNetworkException('No se pudo leer el fichero: $path', cause: e);
    }
  }
}
