import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kylora/data/datasources/local/app_database.dart';
import 'package:kylora/data/datasources/local/live_cache_store.dart';
import 'package:kylora/domain/entities/favorite_channel_group.dart';

void main() {
  test('LiveCacheStore guarda grupos favoritos por cuenta', () async {
    final AppDatabase db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final LiveCacheStore cache = LiveCacheStore(db);
    final FavoriteChannelGroup group = FavoriteChannelGroup(
      categoryId: 42,
      name: 'Deportes',
      isRadio: false,
      addedAt: DateTime(2026, 10, 28, 20),
    );

    await cache.addFavoriteGroup('cuenta-a', group);
    expect(await cache.isFavoriteGroup('cuenta-a', 42), isTrue);
    expect(await cache.getFavoriteGroups('cuenta-a'), hasLength(1));
    expect(await cache.isFavoriteGroup('cuenta-b', 42), isFalse);

    await cache.removeFavoriteGroup('cuenta-a', 42);
    expect(await cache.isFavoriteGroup('cuenta-a', 42), isFalse);
  });
}
