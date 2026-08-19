import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Categorías de canales en directo (caché local).
class LiveCategories extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Canales en directo (caché local). El stream_id es la clave natural de la fuente.
@TableIndex(name: 'live_channels_name_idx', columns: {#name})
class LiveChannels extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get streamId => integer().unique()();
  TextColumn get name => text()();
  IntColumn get categoryId => integer()();
  IntColumn get number => integer().nullable()();
  TextColumn get logo => text().nullable()();
  TextColumn get epgChannelId => text().nullable()();
}

/// Tipo de contenido para favoritos e historial.
enum ContentType { live, vod, series }

/// Favoritos del usuario (persistente).
class Favorites extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get contentId => integer()();
  TextColumn get contentType => text()();
  TextColumn get name => text()();
  TextColumn get logo => text().nullable()();
  DateTimeColumn get addedAt => dateTime()();
}

/// Historial de reproducción (persistente).
class History extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get contentId => integer()();
  TextColumn get contentType => text()();
  TextColumn get name => text()();
  TextColumn get logo => text().nullable()();
  DateTimeColumn get watchedAt => dateTime()();
  IntColumn get position => integer().withDefault(const Constant(0))();
  IntColumn get duration => integer().nullable()();
}

@DriftDatabase(tables: <Type>[LiveCategories, LiveChannels, Favorites, History])
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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) => m.createAll(),
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(favorites);
          await m.createTable(history);
        }
      },
    );
  }
}
