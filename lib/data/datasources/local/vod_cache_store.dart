import 'package:drift/drift.dart';

import '../../../domain/entities/category.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/entities/series.dart';
import 'app_database.dart';

/// Caché local de catálogos VOD y series, particionada por cuenta.
class VodCacheStore {
  VodCacheStore(this._db);

  final AppDatabase _db;

  Future<List<Category>> getVodCategories(String accountKey) async {
    final List<VodCategory> rows =
        await (_db.select(_db.vodCategories)
              ..where((VodCategories t) => t.accountKey.equals(accountKey))
              ..orderBy(<OrderingTerm Function(VodCategories)>[
                (VodCategories t) => OrderingTerm.asc(t.id),
              ]))
            .get();
    return rows
        .map((VodCategory row) => Category(id: row.id, name: row.name))
        .toList();
  }

  Future<List<Movie>> getVodMovies(String accountKey, {int? categoryId}) async {
    final query = _db.select(_db.vodMovies)
      ..where((VodMovies t) => t.accountKey.equals(accountKey))
      ..orderBy(<OrderingTerm Function(VodMovies)>[
        (VodMovies t) => OrderingTerm.asc(t.number),
      ]);
    if (categoryId != null) {
      query.where((VodMovies t) => t.categoryId.equals(categoryId));
    }
    final List<VodMovy> rows = await query.get();
    return rows.map(_toMovie).toList();
  }

  Future<void> replaceVodContent({
    required String accountKey,
    required List<Category> categories,
    required List<Movie> movies,
  }) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.vodCategories,
      )..where((VodCategories t) => t.accountKey.equals(accountKey))).go();
      await (_db.delete(
        _db.vodMovies,
      )..where((VodMovies t) => t.accountKey.equals(accountKey))).go();
      await _db.batch((Batch batch) {
        batch.insertAll(
          _db.vodCategories,
          categories
              .map(
                (Category category) => VodCategoriesCompanion.insert(
                  accountKey: Value(accountKey),
                  id: category.id,
                  name: category.name,
                ),
              )
              .toList(),
        );
        batch.insertAll(
          _db.vodMovies,
          movies
              .map((Movie movie) => _toInsertable(accountKey, movie))
              .toList(),
        );
      });
    });
  }

  Future<List<Category>> getSeriesCategories(String accountKey) async {
    final List<SeriesCategory> rows =
        await (_db.select(_db.seriesCategories)
              ..where((SeriesCategories t) => t.accountKey.equals(accountKey))
              ..orderBy(<OrderingTerm Function(SeriesCategories)>[
                (SeriesCategories t) => OrderingTerm.asc(t.id),
              ]))
            .get();
    return rows
        .map((SeriesCategory row) => Category(id: row.id, name: row.name))
        .toList();
  }

  Future<List<Series>> getSeries(String accountKey, {int? categoryId}) async {
    final query = _db.select(_db.seriesCache)
      ..where((SeriesCache t) => t.accountKey.equals(accountKey))
      ..orderBy(<OrderingTerm Function(SeriesCache)>[
        (SeriesCache t) => OrderingTerm.asc(t.name),
      ]);
    if (categoryId != null) {
      query.where((SeriesCache t) => t.categoryId.equals(categoryId));
    }
    final List<SeriesCacheData> rows = await query.get();
    return rows.map(_toSeries).toList();
  }

  Future<void> replaceSeriesContent({
    required String accountKey,
    required List<Category> categories,
    required List<Series> series,
  }) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.seriesCategories,
      )..where((SeriesCategories t) => t.accountKey.equals(accountKey))).go();
      await (_db.delete(
        _db.seriesCache,
      )..where((SeriesCache t) => t.accountKey.equals(accountKey))).go();
      await _db.batch((Batch batch) {
        batch.insertAll(
          _db.seriesCategories,
          categories
              .map(
                (Category category) => SeriesCategoriesCompanion.insert(
                  accountKey: Value(accountKey),
                  id: category.id,
                  name: category.name,
                ),
              )
              .toList(),
        );
        batch.insertAll(
          _db.seriesCache,
          series
              .map((Series item) => _toSeriesInsertable(accountKey, item))
              .toList(),
        );
      });
    });
  }

  Future<void> clear() async {
    await _db.transaction(() async {
      await _db.delete(_db.vodCategories).go();
      await _db.delete(_db.vodMovies).go();
      await _db.delete(_db.seriesCategories).go();
      await _db.delete(_db.seriesCache).go();
    });
  }

  Movie _toMovie(VodMovy row) => Movie(
    id: row.streamId,
    name: row.name,
    categoryId: row.categoryId,
    number: row.number,
    streamType: row.streamType,
    streamIcon: row.streamIcon,
    rating: row.rating,
    rating5Based: row.rating5Based,
    added: row.added,
    containerExtension: row.containerExtension,
    customSkin: row.customSkin,
    directSource: row.directSource,
  );

  VodMoviesCompanion _toInsertable(String accountKey, Movie movie) =>
      VodMoviesCompanion.insert(
        accountKey: Value(accountKey),
        streamId: movie.id,
        name: movie.name,
        categoryId: movie.categoryId,
        number: Value<int?>(movie.number),
        streamType: Value<String?>(movie.streamType),
        streamIcon: Value<String?>(movie.streamIcon),
        rating: Value<String?>(movie.rating),
        rating5Based: Value<String?>(movie.rating5Based),
        added: Value<String?>(movie.added),
        containerExtension: Value<String?>(movie.containerExtension),
        customSkin: Value<String?>(movie.customSkin),
        directSource: Value<String?>(movie.directSource),
      );

  Series _toSeries(SeriesCacheData row) => Series(
    id: row.seriesId,
    name: row.name,
    number: row.number,
    season: row.season,
    cover: row.cover,
    plot: row.plot,
    cast: row.cast,
    director: row.director,
    genre: row.genre,
    releaseDate: row.releaseDate,
    lastModified: row.lastModified,
    rating: row.rating,
    rating5Based: row.rating5Based,
    backdropPath: row.backdropPath,
    youtubeTrailer: row.youtubeTrailer,
    episodeRunTime: row.episodeRunTime,
    categoryId: row.categoryId,
  );

  SeriesCacheCompanion _toSeriesInsertable(String accountKey, Series item) =>
      SeriesCacheCompanion.insert(
        accountKey: Value(accountKey),
        seriesId: item.id,
        name: item.name,
        number: Value<int?>(item.number),
        season: Value<int?>(item.season),
        cover: Value<String?>(item.cover),
        plot: Value<String?>(item.plot),
        cast: Value<String?>(item.cast),
        director: Value<String?>(item.director),
        genre: Value<String?>(item.genre),
        releaseDate: Value<String?>(item.releaseDate),
        lastModified: Value<String?>(item.lastModified),
        rating: Value<String?>(item.rating),
        rating5Based: Value<String?>(item.rating5Based),
        backdropPath: Value<String?>(item.backdropPath),
        youtubeTrailer: Value<String?>(item.youtubeTrailer),
        episodeRunTime: Value<String?>(item.episodeRunTime),
        categoryId: Value<int?>(item.categoryId),
      );
}
