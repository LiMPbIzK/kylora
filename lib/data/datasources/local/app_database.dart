import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Categorías de canales en directo (caché local, por cuenta).
class LiveCategories extends Table {
  /// Id de la cuenta (fingerprint) a la que pertenece la fila.
  TextColumn get accountKey => text().withDefault(const Constant(''))();
  IntColumn get id => integer()();
  TextColumn get name => text()();

  @override
  Set<Column<Object>> get primaryKey => {accountKey, id};
}

/// Canales en directo (caché local). El stream_id es la clave natural de la fuente
/// (no unique: puede repetirse entre cuentas distintas).
@TableIndex(name: 'live_channels_name_idx', columns: {#name})
class LiveChannels extends Table {
  /// Id de la cuenta (fingerprint) a la que pertenece la fila.
  TextColumn get accountKey => text().withDefault(const Constant(''))();
  IntColumn get id => integer().autoIncrement()();
  IntColumn get streamId => integer()();
  TextColumn get name => text()();
  IntColumn get categoryId => integer()();
  IntColumn get number => integer().nullable()();
  TextColumn get logo => text().nullable()();
  TextColumn get epgChannelId => text().nullable()();
  BoolColumn get hasArchive => boolean().withDefault(const Constant(false))();
  IntColumn get archiveDurationDays => integer().nullable()();
}

/// Categorías de películas (VOD), por cuenta.
class VodCategories extends Table {
  TextColumn get accountKey => text().withDefault(const Constant(''))();
  IntColumn get id => integer()();
  TextColumn get name => text()();

  @override
  Set<Column<Object>> get primaryKey => {accountKey, id};
}

/// Películas (VOD) cacheadas, por cuenta.
@TableIndex(name: 'vod_movies_name_idx', columns: {#name})
class VodMovies extends Table {
  TextColumn get accountKey => text().withDefault(const Constant(''))();
  IntColumn get id => integer().autoIncrement()();
  IntColumn get streamId => integer()();
  TextColumn get name => text()();
  IntColumn get categoryId => integer()();
  IntColumn get number => integer().nullable()();
  TextColumn get streamType => text().nullable()();
  TextColumn get streamIcon => text().nullable()();
  TextColumn get rating => text().nullable()();
  TextColumn get rating5Based => text().nullable()();
  TextColumn get added => text().nullable()();
  TextColumn get containerExtension => text().nullable()();
  TextColumn get customSkin => text().nullable()();
  TextColumn get directSource => text().nullable()();
}

/// Categorías de series, por cuenta.
class SeriesCategories extends Table {
  TextColumn get accountKey => text().withDefault(const Constant(''))();
  IntColumn get id => integer()();
  TextColumn get name => text()();

  @override
  Set<Column<Object>> get primaryKey => {accountKey, id};
}

/// Series cacheadas, por cuenta.
@TableIndex(name: 'series_cache_name_idx', columns: {#name})
class SeriesCache extends Table {
  TextColumn get accountKey => text().withDefault(const Constant(''))();
  IntColumn get id => integer().autoIncrement()();
  IntColumn get seriesId => integer()();
  TextColumn get name => text()();
  IntColumn get number => integer().nullable()();
  IntColumn get season => integer().nullable()();
  TextColumn get cover => text().nullable()();
  TextColumn get plot => text().nullable()();
  TextColumn get cast => text().nullable()();
  TextColumn get director => text().nullable()();
  TextColumn get genre => text().nullable()();
  TextColumn get releaseDate => text().nullable()();
  TextColumn get lastModified => text().nullable()();
  TextColumn get rating => text().nullable()();
  TextColumn get rating5Based => text().nullable()();
  TextColumn get backdropPath => text().nullable()();
  TextColumn get youtubeTrailer => text().nullable()();
  TextColumn get episodeRunTime => text().nullable()();
  IntColumn get categoryId => integer().nullable()();
}

/// Tipo de contenido para favoritos e historial.
enum ContentType { live, vod, series }

/// Favoritos del usuario (persistente, por cuenta).
class Favorites extends Table {
  /// Id de la cuenta (fingerprint) a la que pertenece la fila.
  TextColumn get accountKey => text().withDefault(const Constant(''))();
  IntColumn get id => integer().autoIncrement()();
  IntColumn get contentId => integer()();
  TextColumn get contentType => text()();
  TextColumn get name => text()();
  TextColumn get logo => text().nullable()();
  DateTimeColumn get addedAt => dateTime()();
}

/// Historial de reproducción (persistente, por cuenta).
class History extends Table {
  /// Id de la cuenta (fingerprint) a la que pertenece la fila.
  TextColumn get accountKey => text().withDefault(const Constant(''))();
  IntColumn get id => integer().autoIncrement()();
  IntColumn get contentId => integer()();
  TextColumn get contentType => text()();
  TextColumn get name => text()();
  TextColumn get logo => text().nullable()();
  DateTimeColumn get watchedAt => dateTime()();
  IntColumn get position => integer().withDefault(const Constant(0))();
  IntColumn get duration => integer().nullable()();

  /// URL del stream en el momento de la reproducción (para "Continuar
  /// visualización" sin depender de estado de sesión/catálogo al reanudar).
  TextColumn get streamUrl => text().nullable()();
}

/// Preferencias de la aplicación (pares clave-valor: locale, tema, PIN, ...).
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(
  tables: <Type>[
    LiveCategories,
    LiveChannels,
    VodCategories,
    VodMovies,
    SeriesCategories,
    SeriesCache,
    Favorites,
    History,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? _openDefaultConnection());

  /// Crea el conector nativo SQLite en el directorio de documentos de la app.
  static QueryExecutor _openDefaultConnection() {
    return LazyDatabase(() async {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File(p.join(directory.path, 'kylora.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) => m.createAll(),
      beforeOpen: (details) async {
        // Los datos huérfanos de la v3 (accountKey = '') se adoptan a la cuenta
        // activa en el primer arranque tras la migración (ver AuthStore.getAll /
        // repositorios). La caché de canales se re-descarga al cambiar de cuenta.
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(favorites);
          await m.createTable(history);
        }
        if (from < 3) {
          await m.createTable(appSettings);
        }
        if (from < 4) {
          // V4: las tablas de datos del usuario pasan a estar particionadas por
          // cuenta (accountKey). Las columnas nuevas se rellenan con ''.
          await m.addColumn(liveCategories, liveCategories.accountKey);
          await m.addColumn(liveChannels, liveChannels.accountKey);
          await m.addColumn(favorites, favorites.accountKey);
          await m.addColumn(history, history.accountKey);
        }
        if (from < 5) {
          // V5: guarda la URL del stream en el historial para poder reanudar
          // ("Continuar visualización") sin depender del catálogo.
          await m.addColumn(history, history.streamUrl);
        }
        if (from < 6) {
          // V6: datos de catch-up/timeshift del canal.
          await m.addColumn(liveChannels, liveChannels.hasArchive);
          await m.addColumn(liveChannels, liveChannels.archiveDurationDays);
          // La caché anterior no tiene los nuevos campos; se re-descarga al
          // abrir el catálogo la próxima vez.
          await delete(liveChannels).go();
        }
        if (from < 7) {
          // V7: caché de catálogos VOD y series.
          await m.createTable(vodCategories);
          await m.createTable(vodMovies);
          await m.createTable(seriesCategories);
          await m.createTable(seriesCache);
        }
      },
    );
  }
}
