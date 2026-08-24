import 'package:drift/drift.dart';

import 'app_database.dart';

/// Contrato del almacén de preferencias para poder sustituirlo en tests.
abstract interface class AppSettingsStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String? value);
}

/// Preferencias de la aplicación persistidas en una tabla clave-valor (Drift).
///
/// Claves: `locale` (código de idioma), `themeId` (clave del registro
/// `AppThemes`) y, en el futuro, `pinEnabled`.
class SettingsStore implements AppSettingsStorage {
  SettingsStore(this._db);

  final AppDatabase _db;

  static const String kLocale = 'locale';
  static const String kThemeId = 'theme_id';
  static const String kPinEnabled = 'pin_enabled';

  @override
  Future<String?> read(String key) async {
    final AppSetting? row = await (_db.select(_db.appSettings)
          ..where((AppSettings t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  @override
  Future<void> write(String key, String? value) async {
    if (value == null) {
      await (_db.delete(_db.appSettings)
            ..where((AppSettings t) => t.key.equals(key)))
          .go();
      return;
    }
    await _db.into(_db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: key,
            value: Value<String?>(value),
          ),
        );
  }
}