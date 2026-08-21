import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../domain/entities/iptv_source_type.dart';

/// Sesión guardada de forma segura para cualquier fuente IPTV.
class StoredCredentials {
  const StoredCredentials({
    required this.serverUrl,
    required this.username,
    required this.password,
    required this.sourceType,
    this.m3uUrl,
    this.xmltvUrl,
  });

  /// URL del servidor (Xtream) o de la lista M3U principal.
  final String serverUrl;

  /// Usuario (Xtream) o vacío en fuentes M3U.
  final String username;

  /// Contraseña (Xtream) o vacía en fuentes M3U.
  final String password;

  /// Tipo de fuente asociado a la sesión.
  final IptvSourceType sourceType;

  /// URL de la lista M3U (solo fuentes M3U).
  final String? m3uUrl;

  /// URL opcional de la guía EPG XMLTV (solo fuentes M3U).
  final String? xmltvUrl;

  /// URL que identifica la fuente según su tipo.
  String get sourceUrl =>
      sourceType == IptvSourceType.xtream ? serverUrl : (m3uUrl ?? serverUrl);
}

/// Almacenamiento cifrado de credenciales (flutter_secure_storage).
class AuthStore {
  AuthStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _kServerUrl = 'xtream_server_url';
  static const String _kUsername = 'xtream_username';
  static const String _kPassword = 'xtream_password';
  static const String _kSourceType = 'iptv_source_type';
  static const String _kM3uUrl = 'm3u_url';
  static const String _kXmltvUrl = 'xmltv_url';

  final FlutterSecureStorage _storage;

  Future<StoredCredentials?> read() async {
    final String? serverUrl = await _storage.read(key: _kServerUrl);
    final String? sourceTypeRaw = await _storage.read(key: _kSourceType);
    if (serverUrl == null) return null;

    final IptvSourceType sourceType = sourceTypeRaw == 'm3u'
        ? IptvSourceType.m3u
        : IptvSourceType.xtream;

    if (sourceType == IptvSourceType.m3u) {
      final String? m3uUrl = await _storage.read(key: _kM3uUrl);
      if (m3uUrl == null) return null;
      return StoredCredentials(
        serverUrl: serverUrl,
        username: await _storage.read(key: _kUsername) ?? '',
        password: await _storage.read(key: _kPassword) ?? '',
        sourceType: sourceType,
        m3uUrl: m3uUrl,
        xmltvUrl: await _storage.read(key: _kXmltvUrl),
      );
    }

    final String? username = await _storage.read(key: _kUsername);
    final String? password = await _storage.read(key: _kPassword);
    if (username == null || password == null) return null;
    return StoredCredentials(
      serverUrl: serverUrl,
      username: username,
      password: password,
      sourceType: sourceType,
    );
  }

  Future<void> write(StoredCredentials credentials) async {
    await _storage.write(key: _kServerUrl, value: credentials.serverUrl);
    await _storage.write(
      key: _kSourceType,
      value: credentials.sourceType.name,
    );
    await _storage.write(key: _kUsername, value: credentials.username);
    await _storage.write(key: _kPassword, value: credentials.password);
    if (credentials.sourceType == IptvSourceType.m3u) {
      await _storage.write(key: _kM3uUrl, value: credentials.m3uUrl ?? '');
      await _storage.write(
        key: _kXmltvUrl,
        value: credentials.xmltvUrl ?? '',
      );
    }
  }

  Future<void> clear() async {
    await _storage.delete(key: _kServerUrl);
    await _storage.delete(key: _kUsername);
    await _storage.delete(key: _kPassword);
    await _storage.delete(key: _kSourceType);
    await _storage.delete(key: _kM3uUrl);
    await _storage.delete(key: _kXmltvUrl);
  }
}
