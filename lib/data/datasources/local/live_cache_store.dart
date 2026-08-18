import 'package:drift/drift.dart';

import '../../../domain/entities/category.dart';
import '../../../domain/entities/channel.dart';
import 'app_database.dart';

/// Caché local del catálogo en directo usando Drift.
/// Persiste categorías y canales para acceso sin conexión.
class LiveCacheStore {
  LiveCacheStore(this._db);

  final AppDatabase _db;

  Future<List<Category>> getCategories() async {
    final List<LiveCategory> rows = await _db.select(_db.liveCategories).get();
    return rows
        .map((LiveCategory row) => Category(id: row.id, name: row.name))
        .toList();
  }

  Future<List<Channel>> getChannels({int? categoryId}) async {
    final query = _db.select(_db.liveChannels)
      ..orderBy([(LiveChannels row) => OrderingTerm.asc(row.number)]);
    if (categoryId != null) {
      query.where((LiveChannels row) => row.categoryId.equals(categoryId));
    }
    final List<LiveChannel> rows = await query.get();
    return rows.map(_toChannel).toList();
  }

  Future<void> replaceLiveContent({
    required List<Category> categories,
    required List<Channel> channels,
  }) async {
    await _db.transaction(() async {
      await _db.delete(_db.liveCategories).go();
      await _db.delete(_db.liveChannels).go();
      await _db.batch((Batch batch) {
        batch.insertAll(
          _db.liveCategories,
          categories
              .map(
                (Category category) => LiveCategoriesCompanion.insert(
                  id: Value<int>(category.id),
                  name: category.name,
                ),
              )
              .toList(),
        );
        batch.insertAll(_db.liveChannels, channels.map(_toInsertable).toList());
      });
    });
  }

  Channel _toChannel(LiveChannel row) => Channel(
    id: row.streamId,
    name: row.name,
    categoryId: row.categoryId,
    number: row.number,
    logo: row.logo,
    epgChannelId: row.epgChannelId,
  );

  LiveChannelsCompanion _toInsertable(Channel channel) =>
      LiveChannelsCompanion.insert(
        streamId: channel.id,
        name: channel.name,
        categoryId: channel.categoryId,
        number: Value<int?>(channel.number),
        logo: Value<String?>(channel.logo),
        epgChannelId: Value<String?>(channel.epgChannelId),
      );
}
