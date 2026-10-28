import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../domain/entities/iptv_source_type.dart';
import '../../../domain/entities/saved_account.dart';

/// Contrato de almacenamiento de cuentas, para poder sustituirlo en tests.
abstract interface class AccountStore {
  Future<StoredCredentials?> read();

  Future<void> write(
    StoredCredentials credentials, {
    String? label,
    bool activate = true,
  });

  Future<void> clear();

  Future<List<StoredAccount>> readAll();

  Future<String?> readActiveId();

  Future<void> setActive(String id);

  Future<void> rename(String id, String label);

  Future<void> remove(String id);
}

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

  /// Identificador estable de la cuenta: nucleo para particionar caché,
  /// favoritos e historial por cuenta.
  String get fingerprint {
    if (sourceType == IptvSourceType.xtream) {
      return 'xtream|$serverUrl|$username';
    }
    return 'm3u|${m3uUrl ?? serverUrl}';
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'serverUrl': serverUrl,
    'username': username,
    'password': password,
    'sourceType': sourceType.name,
    'm3uUrl': m3uUrl,
    'xmltvUrl': xmltvUrl,
  };

  factory StoredCredentials.fromJson(Map<String, Object?> json) {
    final String source = json['sourceType'] as String? ?? 'xtream';
    return StoredCredentials(
      serverUrl: json['serverUrl'] as String? ?? '',
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      sourceType: source == IptvSourceType.m3u.name
          ? IptvSourceType.m3u
          : IptvSourceType.xtream,
      m3uUrl: json['m3uUrl'] as String?,
      xmltvUrl: json['xmltvUrl'] as String?,
    );
  }
}

/// Cuenta guardada: credenciales + etiqueta visible en Ajustes.
class StoredAccount {
  const StoredAccount({required this.credentials, required this.label});

  final StoredCredentials credentials;
  final String label;

  String get id => credentials.fingerprint;

  SavedAccount toSavedAccount() => SavedAccount(
    id: id,
    label: label,
    sourceType: credentials.sourceType,
    serverUrl: credentials.sourceUrl,
    username: credentials.username,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'label': label,
    'credentials': credentials.toJson(),
  };

  factory StoredAccount.fromJson(Map<String, Object?> json) {
    final Object? rawCredentials = json['credentials'];
    if (rawCredentials is! Map) {
      throw const FormatException('Cuenta sin credenciales');
    }
    final StoredCredentials credentials = StoredCredentials.fromJson(
      Map<String, Object?>.from(rawCredentials),
    );
    final String label = (json['label'] as String? ?? '').trim();
    return StoredAccount(
      credentials: credentials,
      label: label.isEmpty ? _defaultAccountLabel(credentials) : label,
    );
  }
}

String _defaultAccountLabel(StoredCredentials credentials) {
  final String? host = Uri.tryParse(credentials.sourceUrl)?.host;
  final String fallback = host == null || host.isEmpty
      ? credentials.sourceUrl
      : host;
  if (credentials.sourceType == IptvSourceType.m3u) {
    return 'M3U · $fallback';
  }
  return credentials.username.isEmpty
      ? fallback
      : '${credentials.username} · $fallback';
}

/// Almacenamiento cifrado de credenciales (flutter_secure_storage).
///
/// Mantiene una lista de cuentas y una cuenta activa. El método [read] sigue
/// devolviendo las credenciales activas para que los repositorios no tengan que
/// cambiar. [clear] desactiva la cuenta activa pero conserva las guardadas.
class AuthStore implements AccountStore {
  AuthStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _kLegacyServerUrl = 'xtream_server_url';
  static const String _kLegacyUsername = 'xtream_username';
  static const String _kLegacyPassword = 'xtream_password';
  static const String _kLegacySourceType = 'iptv_source_type';
  static const String _kLegacyM3uUrl = 'm3u_url';
  static const String _kLegacyXmltvUrl = 'xmltv_url';

  static const String _kAccounts = 'iptv_accounts';
  static const String _kActiveAccount = 'iptv_active_account';

  final FlutterSecureStorage _storage;

  @override
  Future<List<StoredAccount>> readAll() async {
    final String? raw = await _storage.read(key: _kAccounts);
    if (raw != null && raw.isNotEmpty) {
      try {
        final Object? decoded = jsonDecode(raw);
        if (decoded is List) {
          final List<StoredAccount> accounts = <StoredAccount>[];
          for (final Object? item in decoded) {
            if (item is! Map) continue;
            try {
              accounts.add(
                StoredAccount.fromJson(Map<String, Object?>.from(item)),
              );
            } on FormatException {
              // Una entrada corrupta no debe impedir usar el resto.
            }
          }
          if (accounts.isNotEmpty) return accounts;
        }
      } on FormatException {
        // Si el JSON está corrupto, se intenta migrar desde el formato antiguo.
      }
    }

    final StoredCredentials? legacy = await _readLegacy();
    if (legacy == null) return const <StoredAccount>[];

    final StoredAccount account = StoredAccount(
      credentials: legacy,
      label: _defaultAccountLabel(legacy),
    );
    await _persist(<StoredAccount>[account], activeId: account.id);
    return <StoredAccount>[account];
  }

  @override
  Future<StoredCredentials?> read() async {
    final List<StoredAccount> accounts = await readAll();
    if (accounts.isEmpty) return null;

    final String? activeId = await _storage.read(key: _kActiveAccount);
    // Sin cuenta activa explícita (p. ej. tras cerrar sesión) no se reactiva
    // automáticamente la primera: las cuentas siguen guardadas para elegirlas.
    if (activeId == null) return null;
    for (final StoredAccount account in accounts) {
      if (account.id == activeId) return account.credentials;
    }
    return null;
  }

  @override
  Future<void> write(
    StoredCredentials credentials, {
    String? label,
    bool activate = true,
  }) async {
    final List<StoredAccount> accounts = (await readAll()).toList();
    final int index = accounts.indexWhere(
      (StoredAccount account) => account.id == credentials.fingerprint,
    );
    final String normalizedLabel = (label?.trim().isNotEmpty ?? false)
        ? label!.trim()
        : index >= 0
        ? accounts[index].label
        : _defaultAccountLabel(credentials);

    final StoredAccount account = StoredAccount(
      credentials: credentials,
      label: normalizedLabel,
    );
    if (index >= 0) {
      accounts[index] = account;
    } else {
      accounts.add(account);
    }
    final String? activeId = activate
        ? account.id
        : await _storage.read(key: _kActiveAccount);
    await _persist(accounts, activeId: activeId);
  }

  @override
  Future<void> clear() async {
    // Migra primero el formato antiguo para no reactivarlo accidentalmente.
    await readAll();
    await _storage.delete(key: _kActiveAccount);
    await _clearLegacy();
  }

  @override
  Future<String?> readActiveId() => _storage.read(key: _kActiveAccount);

  @override
  Future<void> setActive(String id) async {
    final List<StoredAccount> accounts = await readAll();
    if (accounts.any((StoredAccount account) => account.id == id)) {
      await _storage.write(key: _kActiveAccount, value: id);
    }
  }

  @override
  Future<void> rename(String id, String label) async {
    final String trimmed = label.trim();
    if (trimmed.isEmpty) return;
    final List<StoredAccount> accounts = (await readAll()).toList();
    final int index = accounts.indexWhere(
      (StoredAccount account) => account.id == id,
    );
    if (index < 0) return;
    accounts[index] = StoredAccount(
      credentials: accounts[index].credentials,
      label: trimmed,
    );
    final String? activeId = await _storage.read(key: _kActiveAccount);
    await _persist(accounts, activeId: activeId);
  }

  @override
  Future<void> remove(String id) async {
    final List<StoredAccount> accounts = (await readAll()).toList()
      ..removeWhere((StoredAccount account) => account.id == id);

    final String? activeId = await _storage.read(key: _kActiveAccount);
    final String? nextActive = activeId == id
        ? (accounts.isEmpty ? null : accounts.first.id)
        : activeId;
    await _persist(accounts, activeId: nextActive);
  }

  Future<void> _persist(
    List<StoredAccount> accounts, {
    required String? activeId,
  }) async {
    await _storage.write(
      key: _kAccounts,
      value: jsonEncode(
        accounts.map((StoredAccount account) => account.toJson()).toList(),
      ),
    );
    if (activeId == null) {
      await _storage.delete(key: _kActiveAccount);
    } else {
      await _storage.write(key: _kActiveAccount, value: activeId);
    }
    await _clearLegacy();
  }

  Future<StoredCredentials?> _readLegacy() async {
    final String? serverUrl = await _storage.read(key: _kLegacyServerUrl);
    final String? sourceTypeRaw = await _storage.read(key: _kLegacySourceType);
    if (serverUrl == null) return null;

    final IptvSourceType sourceType = sourceTypeRaw == 'm3u'
        ? IptvSourceType.m3u
        : IptvSourceType.xtream;

    if (sourceType == IptvSourceType.m3u) {
      final String? m3uUrl = await _storage.read(key: _kLegacyM3uUrl);
      if (m3uUrl == null) return null;
      return StoredCredentials(
        serverUrl: serverUrl,
        username: await _storage.read(key: _kLegacyUsername) ?? '',
        password: await _storage.read(key: _kLegacyPassword) ?? '',
        sourceType: sourceType,
        m3uUrl: m3uUrl,
        xmltvUrl: await _storage.read(key: _kLegacyXmltvUrl),
      );
    }

    final String? username = await _storage.read(key: _kLegacyUsername);
    final String? password = await _storage.read(key: _kLegacyPassword);
    if (username == null || password == null) return null;
    return StoredCredentials(
      serverUrl: serverUrl,
      username: username,
      password: password,
      sourceType: sourceType,
    );
  }

  Future<void> _clearLegacy() async {
    await _storage.delete(key: _kLegacyServerUrl);
    await _storage.delete(key: _kLegacyUsername);
    await _storage.delete(key: _kLegacyPassword);
    await _storage.delete(key: _kLegacySourceType);
    await _storage.delete(key: _kLegacyM3uUrl);
    await _storage.delete(key: _kLegacyXmltvUrl);
  }
}
