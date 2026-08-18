import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Credenciales Xtream guardadas de forma segura.
class StoredCredentials {
  const StoredCredentials({
    required this.serverUrl,
    required this.username,
    required this.password,
  });

  final String serverUrl;
  final String username;
  final String password;
}

/// Almacenamiento cifrado de credenciales (flutter_secure_storage).
class AuthStore {
  AuthStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _kServerUrl = 'xtream_server_url';
  static const String _kUsername = 'xtream_username';
  static const String _kPassword = 'xtream_password';

  final FlutterSecureStorage _storage;

  Future<StoredCredentials?> read() async {
    final String? serverUrl = await _storage.read(key: _kServerUrl);
    final String? username = await _storage.read(key: _kUsername);
    final String? password = await _storage.read(key: _kPassword);
    if (serverUrl == null || username == null || password == null) {
      return null;
    }
    return StoredCredentials(
      serverUrl: serverUrl,
      username: username,
      password: password,
    );
  }

  Future<void> write(StoredCredentials credentials) async {
    await _storage.write(key: _kServerUrl, value: credentials.serverUrl);
    await _storage.write(key: _kUsername, value: credentials.username);
    await _storage.write(key: _kPassword, value: credentials.password);
  }

  Future<void> clear() async {
    await _storage.delete(key: _kServerUrl);
    await _storage.delete(key: _kUsername);
    await _storage.delete(key: _kPassword);
  }
}
