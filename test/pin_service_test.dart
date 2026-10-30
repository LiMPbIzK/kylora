import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kylora/data/datasources/local/pin_service.dart';

class _MemorySecureStorage extends FlutterSecureStorage {
  final Map<String, String> data = <String, String>{};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => data[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      data.remove(key);
    } else {
      data[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    data.remove(key);
  }
}

void main() {
  test('PinService guarda un hash, verifica y desactiva el PIN', () async {
    final PinService service = PinService(storage: _MemorySecureStorage());
    expect(await service.isEnabled(), isFalse);
    expect(await service.setPin('1234'), isTrue);
    expect(await service.isEnabled(), isTrue);
    expect(await service.verify('1234'), isTrue);
    expect(await service.verify('0000'), isFalse);
    await service.disable();
    expect(await service.isEnabled(), isFalse);
  });

  test('PinService rechaza PIN fuera de rango', () async {
    final PinService service = PinService(storage: _MemorySecureStorage());
    expect(await service.setPin('123'), isFalse);
    expect(await service.setPin('123456789'), isFalse);
    expect(await service.setPin('12ab'), isFalse);
  });
}
