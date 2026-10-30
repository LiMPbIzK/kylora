import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// PIN opcional para proteger la gestión de cuentas sin sesión.
///
/// No se guarda el PIN en claro: se almacena un SHA-256 con sal en el
/// almacenamiento seguro del dispositivo.
class PinService {
  PinService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _kHash = 'kylora_account_pin_hash';
  static const String _kSalt = 'kylora_account_pin_salt';

  final FlutterSecureStorage _storage;

  static DateTime? _sessionUnlockedUntil;

  static bool get isSessionUnlocked =>
      _sessionUnlockedUntil != null &&
      _sessionUnlockedUntil!.isAfter(DateTime.now());

  static void markSessionUnlocked() {
    _sessionUnlockedUntil = DateTime.now().add(const Duration(minutes: 10));
  }

  static void clearSession() {
    _sessionUnlockedUntil = null;
  }

  Future<bool> isEnabled() async {
    try {
      final String? hash = await _storage
          .read(key: _kHash)
          .timeout(const Duration(seconds: 1));
      return hash != null && hash.isNotEmpty;
    } catch (_) {
      // En tests o plataformas sin almacén seguro el PIN simplemente no está
      // disponible; no debe romper Ajustes ni el login.
      return false;
    }
  }

  Future<bool> setPin(String pin) async {
    if (!isValidPin(pin)) return false;
    try {
      final Random random = Random.secure();
      final String salt = base64UrlEncode(
        List<int>.generate(16, (_) => random.nextInt(256)),
      ).replaceAll('=', '');
      final String hash = _hash(salt, pin);
      await _storage.write(key: _kSalt, value: salt);
      await _storage.write(key: _kHash, value: hash);
      clearSession();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> verify(String pin) async {
    try {
      final String? salt = await _storage.read(key: _kSalt);
      final String? expected = await _storage.read(key: _kHash);
      if (salt == null || expected == null || expected.isEmpty) return false;
      return _hash(salt, pin) == expected;
    } catch (_) {
      return false;
    }
  }

  Future<void> disable() async {
    clearSession();
    try {
      await _storage.delete(key: _kHash);
      await _storage.delete(key: _kSalt);
    } catch (_) {
      // Sin almacén seguro no hay PIN que borrar.
    }
  }

  static bool isValidPin(String pin) => RegExp(r'^\d{4,8}$').hasMatch(pin);

  String _hash(String salt, String pin) =>
      sha256.convert(utf8.encode('$salt:$pin')).toString();
}
