import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kylora/data/datasources/local/app_database.dart';
import 'package:kylora/data/datasources/local/vod_cache_store.dart';
import 'package:kylora/domain/entities/category.dart';
import 'package:kylora/domain/entities/movie.dart';
import 'package:kylora/domain/entities/series.dart';

void main() {
  test('VodCacheStore guarda y recupera VOD y series por cuenta', () async {
    final AppDatabase db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final VodCacheStore cache = VodCacheStore(db);

    await cache.replaceVodContent(
      accountKey: 'cuenta-a',
      categories: const <Category>[Category(id: 1, name: 'Acción')],
      movies: const <Movie>[
        Movie(
          id: 10,
          name: 'Película',
          categoryId: 1,
          number: 10,
          streamIcon: 'http://img/poster.jpg',
          containerExtension: 'mkv',
          added: '2026-10-28 20:00:00',
        ),
      ],
    );
    await cache.replaceSeriesContent(
      accountKey: 'cuenta-a',
      categories: const <Category>[Category(id: 2, name: 'Drama')],
      series: const <Series>[
        Series(
          id: 20,
          name: 'Serie',
          categoryId: 2,
          cover: 'http://img/cover.jpg',
          lastModified: '2026-10-28 20:00:00',
        ),
      ],
    );

    expect(await cache.getVodCategories('cuenta-a'), hasLength(1));
    final List<Movie> movies = await cache.getVodMovies(
      'cuenta-a',
      categoryId: 1,
    );
    expect(movies.single.name, 'Película');
    expect(movies.single.containerExtension, 'mkv');
    expect(await cache.getSeriesCategories('cuenta-a'), hasLength(1));
    final List<Series> series = await cache.getSeries(
      'cuenta-a',
      categoryId: 2,
    );
    expect(series.single.name, 'Serie');
    expect(await cache.getVodCategories('cuenta-b'), isEmpty);
  });
}
