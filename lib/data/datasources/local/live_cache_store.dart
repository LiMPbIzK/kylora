import 'package:drift/drift.dart';

import '../../../domain/entities/category.dart';
import '../../../domain/entities/channel.dart';
import '../../../domain/entities/favorite_channel_group.dart';
import 'app_database.dart';

/// Caché local del catálogo en directo usando Drift.
/// Persiste categorías y canales por cuenta ([accountKey]) para acceso sin
/// conexión y de modo que cada cuenta vea únicamente su propio catálogo.
class LiveCacheStore {
  LiveCacheStore(this._db);

  final AppDatabase _db;

  Future<List<Category>> getCategories(String accountKey) async {
    final List<LiveCategory> rows = await (_db.select(
      _db.liveCategories,
    )..where((t) => t.accountKey.equals(accountKey))).get();
    return rows
        .map((LiveCategory row) => Category(id: row.id, name: row.name))
        .toList();
  }

  Future<List<Channel>> getChannels(
    String accountKey, {
    int? categoryId,
  }) async {
    final query = _db.select(_db.liveChannels)
      ..where((t) => t.accountKey.equals(accountKey))
      ..orderBy([(LiveChannels row) => OrderingTerm.asc(row.number)]);
    if (categoryId != null) {
      query.where((LiveChannels row) => row.categoryId.equals(categoryId));
    }
    final List<LiveChannel> rows = await query.get();
    return rows.map(_toChannel).toList();
  }

  Future<void> replaceLiveContent({
    required String accountKey,
    required List<Category> categories,
    required List<Channel> channels,
  }) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.liveCategories,
      )..where((LiveCategories t) => t.accountKey.equals(accountKey))).go();
      await (_db.delete(
        _db.liveChannels,
      )..where((LiveChannels t) => t.accountKey.equals(accountKey))).go();
      await _db.batch((Batch batch) {
        batch.insertAll(
          _db.liveCategories,
          categories
              .map(
                (Category category) => LiveCategoriesCompanion.insert(
                  accountKey: Value(accountKey),
                  id: category.id,
                  name: category.name,
                ),
              )
              .toList(),
        );
        batch.insertAll(
          _db.liveChannels,
          channels.map((Channel channel) => _toInsertable(accountKey, channel)),
        );
      });
    });
  }

  /// Vacía la caché local del catálogo en directo (todas las cuentas).
  Future<void> clear() async {
    await _db.transaction(() async {
      await _db.delete(_db.liveCategories).go();
      await _db.delete(_db.liveChannels).go();
    });
  }

  Future<List<FavoriteChannelGroup>> getFavoriteGroups(
    String accountKey,
  ) async {
    final List<FavoriteGroup> rows =
        await (_db.select(_db.favoriteGroups)
              ..where((FavoriteGroups t) => t.accountKey.equals(accountKey))
              ..orderBy(<OrderingTerm Function(FavoriteGroups)>[
                (FavoriteGroups t) => OrderingTerm.asc(t.name),
              ]))
            .get();
    return rows
        .map(
          (FavoriteGroup row) => FavoriteChannelGroup(
            categoryId: row.categoryId,
            name: row.name,
            isRadio: row.isRadio,
            addedAt: row.addedAt,
          ),
        )
        .toList();
  }

  Future<void> addFavoriteGroup(
    String accountKey,
    FavoriteChannelGroup group,
  ) async {
    await _db
        .into(_db.favoriteGroups)
        .insertOnConflictUpdate(
          FavoriteGroupsCompanion.insert(
            accountKey: Value(accountKey),
            categoryId: group.categoryId,
            name: group.name,
            isRadio: Value(group.isRadio),
            addedAt: group.addedAt,
          ),
        );
  }

  Future<void> removeFavoriteGroup(String accountKey, int categoryId) async {
    await (_db.delete(_db.favoriteGroups)
          ..where((FavoriteGroups t) => t.accountKey.equals(accountKey))
          ..where((FavoriteGroups t) => t.categoryId.equals(categoryId)))
        .go();
  }

  Future<bool> isFavoriteGroup(String accountKey, int categoryId) async {
    final List<FavoriteGroup> rows =
        await (_db.select(_db.favoriteGroups)
              ..where((FavoriteGroups t) => t.accountKey.equals(accountKey))
              ..where((FavoriteGroups t) => t.categoryId.equals(categoryId)))
            .get();
    return rows.isNotEmpty;
  }

  Channel _toChannel(LiveChannel row) => Channel(
    id: row.streamId,
    name: row.name,
    categoryId: row.categoryId,
    number: row.number,
    logo: row.logo,
    epgChannelId: row.epgChannelId,
    hasArchive: row.hasArchive,
    archiveDurationDays: row.archiveDurationDays,
  );

  LiveChannelsCompanion _toInsertable(String accountKey, Channel channel) =>
      LiveChannelsCompanion.insert(
        accountKey: Value(accountKey),
        streamId: channel.id,
        name: channel.name,
        categoryId: channel.categoryId,
        number: Value<int?>(channel.number),
        logo: Value<String?>(channel.logo),
        epgChannelId: Value<String?>(channel.epgChannelId),
        hasArchive: Value<bool>(channel.hasArchive),
        archiveDurationDays: Value<int?>(channel.archiveDurationDays),
      );
}
