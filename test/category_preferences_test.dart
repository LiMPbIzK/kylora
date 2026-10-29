import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kylora/data/datasources/local/app_database.dart'
    hide CategoryPreference;
import 'package:kylora/data/datasources/local/live_cache_store.dart';
import 'package:kylora/domain/entities/category_preference.dart';

void main() {
  test(
    'LiveCacheStore guarda visibilidad y orden de categorías por cuenta',
    () async {
      final AppDatabase db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final LiveCacheStore cache = LiveCacheStore(db);

      await cache.replaceCategoryPreferences('cuenta-a', <CategoryPreference>[
        const CategoryPreference(categoryId: 3, sortOrder: 0),
        const CategoryPreference(categoryId: 1, hidden: true, sortOrder: 1),
        const CategoryPreference(categoryId: 2, sortOrder: 2),
      ]);

      final List<CategoryPreference> saved = await cache.getCategoryPreferences(
        'cuenta-a',
      );
      expect(saved, hasLength(3));
      expect(saved[0].categoryId, 3);
      expect(saved[1].hidden, isTrue);
      expect(saved[2].categoryId, 2);
      expect(await cache.getCategoryPreferences('cuenta-b'), isEmpty);

      await cache.replaceCategoryPreferences('cuenta-a', <CategoryPreference>[
        const CategoryPreference(categoryId: 2, sortOrder: 0),
      ]);
      final List<CategoryPreference> replaced = await cache
          .getCategoryPreferences('cuenta-a');
      expect(replaced, hasLength(1));
      expect(replaced.single.categoryId, 2);
    },
  );
}
