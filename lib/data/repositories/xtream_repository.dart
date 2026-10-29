import 'package:drift/drift.dart';

import '../../core/utils/catchup.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/category_preference.dart';
import '../../domain/entities/channel.dart';
import '../../domain/entities/content_type.dart' as domain;
import '../../domain/entities/epg.dart';
import '../../domain/entities/episode.dart';
import '../../domain/entities/favorite_channel_group.dart';
import '../../domain/entities/favorite_item.dart';
import '../../domain/entities/history_item.dart';
import '../../domain/entities/iptv_auth_config.dart';
import '../../domain/entities/iptv_source_type.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/series.dart';
import '../../domain/entities/series_info.dart';
import '../../domain/entities/user_account.dart';
import '../../domain/repositories/iptv_repository.dart';
import '../datasources/local/app_database.dart' hide CategoryPreference;
import '../datasources/local/auth_store.dart';
import '../datasources/local/live_cache_store.dart';
import '../datasources/local/vod_cache_store.dart';
import '../datasources/remote/xtream_api_client.dart';
import '../models/xtream_category_dto.dart';
import '../models/xtream_series_dto.dart';
import '../models/xtream_series_info_dto.dart';
import '../models/xtream_stream_dto.dart';
import '../models/xtream_user_info_dto.dart';
import '../models/xtream_vod_stream_dto.dart';

/// Implementación Xtream del contrato [IptvRepository].
class XtreamRepository implements IptvRepository {
  XtreamRepository(
    this._apiClient,
    this._authStore,
    this._db, {
    LiveCacheStore? cache,
    VodCacheStore? vodCache,
  }) : _cache = cache ?? LiveCacheStore(_db),
       _vodCache = vodCache ?? VodCacheStore(_db);

  final XtreamApiClient _apiClient;
  final AuthStore _authStore;
  final AppDatabase _db;
  final LiveCacheStore _cache;
  final VodCacheStore _vodCache;

  @override
  Future<UserAccount> login(
    IptvAuthConfig config, {
    bool activate = true,
  }) async {
    final XtreamAuthConfig xtream = config as XtreamAuthConfig;
    final StoredCredentials newCredentials = StoredCredentials(
      serverUrl: xtream.serverUrl,
      username: xtream.username,
      password: xtream.password,
      sourceType: IptvSourceType.xtream,
    );
    final StoredCredentials? previous = await _authStore.read();
    if (activate &&
        (previous == null ||
            previous.fingerprint != newCredentials.fingerprint)) {
      // Cuenta distinta que va a activarse: descarta la caché de canales de la
      // cuenta anterior para que el nuevo catálogo se descargue limpio.
      await _cache.clear();
    }
    final XtreamAuthResponse response = await _apiClient.authenticate(
      serverUrl: xtream.serverUrl,
      username: xtream.username,
      password: xtream.password,
    );
    final XtreamUserInfoDto info = response.userInfo;
    final UserAccount account = UserAccount(
      serverUrl: xtream.serverUrl,
      username: xtream.username,
      password: xtream.password,
      status: info.status,
      sourceType: IptvSourceType.xtream,
      expiresAt: info.expiresAt,
      maxConnections: info.maxConnections,
      activeConnections: info.activeConnections,
    );
    await _authStore.write(newCredentials, activate: activate);
    await _adoptOrphans(newCredentials.fingerprint);
    return account;
  }

  @override
  Future<UserAccount?> restoreSession() async {
    final StoredCredentials? credentials = await _authStore.read();
    if (credentials == null) return null;
    try {
      final XtreamAuthResponse response = await _apiClient.authenticate(
        serverUrl: credentials.serverUrl,
        username: credentials.username,
        password: credentials.password,
      );
      await _adoptOrphans(credentials.fingerprint);
      final XtreamUserInfoDto info = response.userInfo;
      return UserAccount(
        serverUrl: credentials.serverUrl,
        username: credentials.username,
        password: credentials.password,
        status: info.status,
        sourceType: IptvSourceType.xtream,
        expiresAt: info.expiresAt,
        maxConnections: info.maxConnections,
        activeConnections: info.activeConnections,
      );
    } on XtreamAuthException {
      await _authStore.clear();
      return null;
    }
  }

  @override
  Future<void> logout() => _authStore.clear();

  @override
  Future<String> buildStreamUrl(Channel channel) async {
    final StoredCredentials credentials = await _requireCredentials();
    return '${credentials.serverUrl}/live/'
        '${Uri.encodeComponent(credentials.username)}/'
        '${Uri.encodeComponent(credentials.password)}/'
        '${channel.id}.ts';
  }

  @override
  Future<String?> buildCatchupUrl({
    required int streamId,
    required bool hasArchive,
    int? archiveDurationDays,
    required EpgEntry program,
  }) async {
    if (!isCatchupAvailable(
      hasArchive: hasArchive,
      archiveDurationDays: archiveDurationDays,
      program: program,
    )) {
      return null;
    }
    final StoredCredentials credentials = await _requireCredentials();
    return buildXtreamCatchupUrl(
      serverUrl: credentials.serverUrl,
      username: credentials.username,
      password: credentials.password,
      streamId: streamId,
      program: program,
    );
  }

  @override
  Future<List<CategoryPreference>> getCategoryPreferences() async {
    final StoredCredentials credentials = await _requireCredentials();
    return _cache.getCategoryPreferences(credentials.fingerprint);
  }

  @override
  Future<void> saveCategoryPreferences(
    List<CategoryPreference> preferences,
  ) async {
    final StoredCredentials credentials = await _requireCredentials();
    await _cache.replaceCategoryPreferences(
      credentials.fingerprint,
      preferences,
    );
  }

  @override
  Future<List<Category>> fetchLiveCategories() async {
    final StoredCredentials credentials = await _requireCredentials();
    final List<Category> cached = await _cache.getCategories(
      credentials.fingerprint,
    );
    if (cached.isNotEmpty) return cached;
    return _refreshLiveContent().then(
      (_) => _cache.getCategories(credentials.fingerprint),
    );
  }

  @override
  Future<List<Category>> fetchVodCategories() async {
    final StoredCredentials credentials = await _requireCredentials();
    final List<Category> cached = await _vodCache.getVodCategories(
      credentials.fingerprint,
    );
    if (cached.isNotEmpty) return cached;
    await _refreshVodContent(credentials);
    return _vodCache.getVodCategories(credentials.fingerprint);
  }

  @override
  Future<List<Movie>> fetchVodStreams({int? categoryId}) async {
    final StoredCredentials credentials = await _requireCredentials();
    final List<Movie> cached = await _vodCache.getVodMovies(
      credentials.fingerprint,
      categoryId: categoryId,
    );
    if (cached.isNotEmpty) return cached;
    await _refreshVodContent(credentials);
    return _vodCache.getVodMovies(
      credentials.fingerprint,
      categoryId: categoryId,
    );
  }

  Future<void> _refreshVodContent(StoredCredentials credentials) async {
    final List<Category> categories = (await _apiClient.fetchVodCategories(
      serverUrl: credentials.serverUrl,
      username: credentials.username,
      password: credentials.password,
    )).map((XtreamCategoryDto category) => category.toEntity()).toList();
    final List<Movie> movies = (await _apiClient.fetchVodStreams(
      serverUrl: credentials.serverUrl,
      username: credentials.username,
      password: credentials.password,
    )).map((XtreamVodStreamDto stream) => stream.toEntity()).toList();
    await _vodCache.replaceVodContent(
      accountKey: credentials.fingerprint,
      categories: categories,
      movies: movies,
    );
  }

  @override
  Future<String> buildVodStreamUrl(Movie movie) async {
    final StoredCredentials credentials = await _requireCredentials();
    final String extension = movie.containerExtension?.isNotEmpty == true
        ? movie.containerExtension!
        : 'mp4';
    return '${credentials.serverUrl}/movie/'
        '${Uri.encodeComponent(credentials.username)}/'
        '${Uri.encodeComponent(credentials.password)}/'
        '${movie.id}.$extension';
  }

  @override
  Future<List<Category>> fetchSeriesCategories() async {
    final StoredCredentials credentials = await _requireCredentials();
    final List<Category> cached = await _vodCache.getSeriesCategories(
      credentials.fingerprint,
    );
    if (cached.isNotEmpty) return cached;
    await _refreshSeriesContent(credentials);
    return _vodCache.getSeriesCategories(credentials.fingerprint);
  }

  @override
  Future<List<Series>> fetchSeries({int? categoryId}) async {
    final StoredCredentials credentials = await _requireCredentials();
    final List<Series> cached = await _vodCache.getSeries(
      credentials.fingerprint,
      categoryId: categoryId,
    );
    if (cached.isNotEmpty) return cached;
    await _refreshSeriesContent(credentials);
    return _vodCache.getSeries(credentials.fingerprint, categoryId: categoryId);
  }

  Future<void> _refreshSeriesContent(StoredCredentials credentials) async {
    final List<Category> categories = (await _apiClient.fetchSeriesCategories(
      serverUrl: credentials.serverUrl,
      username: credentials.username,
      password: credentials.password,
    )).map((XtreamCategoryDto category) => category.toEntity()).toList();
    final List<Series> series = (await _apiClient.fetchSeries(
      serverUrl: credentials.serverUrl,
      username: credentials.username,
      password: credentials.password,
    )).map((XtreamSeriesDto item) => item.toEntity()).toList();
    await _vodCache.replaceSeriesContent(
      accountKey: credentials.fingerprint,
      categories: categories,
      series: series,
    );
  }

  @override
  Future<Map<int, List<EpgEntry>>> fetchMultiChannelEpg(
    List<Channel> channels,
  ) async {
    final StoredCredentials credentials = await _requireCredentials();
    final Map<int, List<EpgEntry>> result = <int, List<EpgEntry>>{};
    // Evita descargar el XMLTV completo del proveedor (puede superar 50 MB)
    // para pintar solo las filas visibles. Se piden los canales en lotes
    // pequeños para no saturar el límite de conexiones.
    const int batchSize = 5;
    for (int start = 0; start < channels.length; start += batchSize) {
      final List<Channel> batch = channels.skip(start).take(batchSize).toList();
      final List<MapEntry<int, List<EpgEntry>>> entries = await Future.wait(
        batch.map((Channel channel) async {
          try {
            final List<EpgEntry> epg = await _apiClient.fetchFullEpg(
              serverUrl: credentials.serverUrl,
              username: credentials.username,
              password: credentials.password,
              streamId: channel.id,
            );
            return MapEntry<int, List<EpgEntry>>(channel.id, epg);
          } catch (_) {
            return MapEntry<int, List<EpgEntry>>(
              channel.id,
              <EpgEntry>[],
            );
          }
        }),
      );
      for (final MapEntry<int, List<EpgEntry>> entry in entries) {
        if (entry.value.isNotEmpty) result[entry.key] = entry.value;
      }
    }
    return result;
  }

  @override
  Future<SeriesInfo> fetchSeriesInfo(int seriesId) async {
    final StoredCredentials credentials = await _requireCredentials();
    final XtreamSeriesInfoDto info = await _apiClient.fetchSeriesInfo(
      serverUrl: credentials.serverUrl,
      username: credentials.username,
      password: credentials.password,
      seriesId: seriesId,
    );
    return info.toEntity(seriesId);
  }

  @override
  Future<String> buildEpisodeStreamUrl(Episode episode) async {
    final StoredCredentials credentials = await _requireCredentials();
    final String extension = episode.containerExtension?.isNotEmpty == true
        ? episode.containerExtension!
        : 'mp4';
    return '${credentials.serverUrl}/series/'
        '${Uri.encodeComponent(credentials.username)}/'
        '${Uri.encodeComponent(credentials.password)}/'
        '${episode.id}.$extension';
  }

  @override
  Future<List<EpgEntry>> fetchShortEpg(int streamId) async {
    final StoredCredentials credentials = await _requireCredentials();
    return _apiClient.fetchShortEpg(
      serverUrl: credentials.serverUrl,
      username: credentials.username,
      password: credentials.password,
      streamId: streamId,
    );
  }

  @override
  Future<List<EpgEntry>> fetchFullEpg(int streamId) async {
    final StoredCredentials credentials = await _requireCredentials();
    return _apiClient.fetchFullEpg(
      serverUrl: credentials.serverUrl,
      username: credentials.username,
      password: credentials.password,
      streamId: streamId,
    );
  }

  @override
  Future<void> addFavoriteGroup(FavoriteChannelGroup group) async {
    final StoredCredentials credentials = await _requireCredentials();
    await _cache.addFavoriteGroup(credentials.fingerprint, group);
  }

  @override
  Future<void> removeFavoriteGroup(int categoryId) async {
    final StoredCredentials credentials = await _requireCredentials();
    await _cache.removeFavoriteGroup(credentials.fingerprint, categoryId);
  }

  @override
  Future<List<FavoriteChannelGroup>> getFavoriteGroups() async {
    final StoredCredentials credentials = await _requireCredentials();
    return _cache.getFavoriteGroups(credentials.fingerprint);
  }

  @override
  Future<bool> isFavoriteGroup(int categoryId) async {
    final StoredCredentials credentials = await _requireCredentials();
    return _cache.isFavoriteGroup(credentials.fingerprint, categoryId);
  }

  @override
  Future<void> addToFavorite(FavoriteItem item) async {
    final StoredCredentials credentials = await _requireCredentials();
    await _db
        .into(_db.favorites)
        .insert(
          FavoritesCompanion.insert(
            accountKey: Value(credentials.fingerprint),
            contentId: item.contentId,
            contentType: item.contentType.name,
            name: item.name,
            logo: Value(item.logo),
            addedAt: DateTime.now(),
          ),
        );
  }

  @override
  Future<void> removeFromFavorite(
    int contentId,
    domain.ContentType type,
  ) async {
    final StoredCredentials credentials = await _requireCredentials();
    await (_db.delete(_db.favorites)
          ..where((f) => f.accountKey.equals(credentials.fingerprint))
          ..where((f) => f.contentId.equals(contentId))
          ..where((f) => f.contentType.equals(type.name)))
        .go();
  }

  @override
  Future<bool> isFavorite(int contentId, domain.ContentType type) async {
    final StoredCredentials credentials = await _requireCredentials();
    final List<Favorite> rows =
        await (_db.select(_db.favorites)
              ..where((f) => f.accountKey.equals(credentials.fingerprint))
              ..where((f) => f.contentId.equals(contentId))
              ..where((f) => f.contentType.equals(type.name)))
            .get();
    return rows.isNotEmpty;
  }

  @override
  Future<List<FavoriteItem>> getFavorites() async {
    final StoredCredentials credentials = await _requireCredentials();
    final List<Favorite> rows = await (_db.select(
      _db.favorites,
    )..where((f) => f.accountKey.equals(credentials.fingerprint))).get();
    return rows
        .map(
          (Favorite row) => FavoriteItem(
            contentId: row.contentId,
            contentType: _parseContentType(row.contentType),
            name: row.name,
            logo: row.logo,
          ),
        )
        .toList();
  }

  @override
  Future<void> addToHistory(HistoryItem item) async {
    final StoredCredentials credentials = await _requireCredentials();
    // Upsert por contenido: una única entrada por (cuenta, contentId, tipo),
    // actualizada con la última posición (necesario para "Continuar visualización").
    final List<HistoryData> existing =
        await (_db.select(_db.history)
              ..where((t) => t.accountKey.equals(credentials.fingerprint))
              ..where((t) => t.contentId.equals(item.contentId))
              ..where((t) => t.contentType.equals(item.contentType.name)))
            .get();
    if (existing.isNotEmpty) {
      final HistoryData row = existing.first;
      final bool furtherProgress = item.position > row.position;
      await (_db.update(_db.history)..where((t) => t.id.equals(row.id))).write(
        HistoryCompanion(
          name: Value(item.name),
          logo: Value(item.logo),
          watchedAt: Value(item.watchedAt),
          position: Value(furtherProgress ? item.position : row.position),
          duration: Value(item.duration ?? row.duration),
          streamUrl: Value(item.streamUrl ?? row.streamUrl),
        ),
      );
      return;
    }
    await _db
        .into(_db.history)
        .insert(
          HistoryCompanion.insert(
            accountKey: Value(credentials.fingerprint),
            contentId: item.contentId,
            contentType: item.contentType.name,
            name: item.name,
            logo: Value(item.logo),
            watchedAt: item.watchedAt,
            position: Value(item.position),
            duration: Value(item.duration),
            streamUrl: Value(item.streamUrl),
          ),
        );
  }

  @override
  Future<List<HistoryItem>> getHistory() async {
    final StoredCredentials credentials = await _requireCredentials();
    final List<HistoryData> rows =
        await (_db.select(_db.history)
              ..where((t) => t.accountKey.equals(credentials.fingerprint))
              ..orderBy([(t) => OrderingTerm.desc(t.watchedAt)]))
            .get();
    return rows
        .map(
          (HistoryData row) => HistoryItem(
            contentId: row.contentId,
            contentType: _parseContentType(row.contentType),
            name: row.name,
            logo: row.logo,
            watchedAt: row.watchedAt,
            position: row.position,
            duration: row.duration,
            streamUrl: row.streamUrl,
          ),
        )
        .toList();
  }

  @override
  Future<void> clearHistory() async {
    final StoredCredentials credentials = await _requireCredentials();
    await (_db.delete(
      _db.history,
    )..where((t) => t.accountKey.equals(credentials.fingerprint))).go();
  }

  @override
  Future<void> removeFromHistory(int contentId, domain.ContentType type) async {
    final StoredCredentials credentials = await _requireCredentials();
    await (_db.delete(_db.history)
          ..where((t) => t.accountKey.equals(credentials.fingerprint))
          ..where((t) => t.contentId.equals(contentId))
          ..where((t) => t.contentType.equals(type.name)))
        .go();
  }

  @override
  Future<void> refreshCatalog() async {
    final StoredCredentials credentials = await _requireCredentials();
    await _refreshLiveContent();
    await _refreshVodContent(credentials);
    await _refreshSeriesContent(credentials);
  }

  @override
  Future<void> clearCatalogCache() async {
    await _cache.clear();
    await _vodCache.clear();
  }

  domain.ContentType _parseContentType(String value) {
    return switch (value) {
      'live' => domain.ContentType.live,
      'vod' => domain.ContentType.vod,
      'series' => domain.ContentType.series,
      _ => domain.ContentType.live,
    };
  }

  @override
  Future<List<Channel>> fetchLiveChannels({int? categoryId}) async {
    final StoredCredentials credentials = await _requireCredentials();
    final List<Channel> cached = await _cache.getChannels(
      credentials.fingerprint,
      categoryId: categoryId,
    );
    if (cached.isNotEmpty) return cached;
    await _refreshLiveContent();
    return _cache.getChannels(credentials.fingerprint, categoryId: categoryId);
  }

  /// Descarga categorías y canales y los persiste en la caché local.
  Future<void> _refreshLiveContent() async {
    final StoredCredentials credentials = await _requireCredentials();
    final List<Category> categories = (await _apiClient.fetchLiveCategories(
      serverUrl: credentials.serverUrl,
      username: credentials.username,
      password: credentials.password,
    )).map((XtreamCategoryDto category) => category.toEntity()).toList();
    final List<Channel> channels = (await _apiClient.fetchLiveStreams(
      serverUrl: credentials.serverUrl,
      username: credentials.username,
      password: credentials.password,
    )).map((XtreamStreamDto stream) => stream.toEntity()).toList();
    await _cache.replaceLiveContent(
      accountKey: credentials.fingerprint,
      categories: categories,
      channels: channels,
    );
  }

  /// Migración v3→v4: reasigna los favoritos e historial huérfanos
  /// (accountKey == '') a la cuenta activa para no perder los datos previos.
  Future<void> _adoptOrphans(String fingerprint) async {
    await _db.transaction(() async {
      await (_db.update(_db.favorites)..where((f) => f.accountKey.equals('')))
          .write(FavoritesCompanion(accountKey: Value(fingerprint)));
      await (_db.update(_db.history)..where((t) => t.accountKey.equals('')))
          .write(HistoryCompanion(accountKey: Value(fingerprint)));
    });
  }

  /// Recupera las credenciales guardadas o lanza si no hay sesión.
  Future<StoredCredentials> _requireCredentials() async {
    final StoredCredentials? credentials = await _authStore.read();
    if (credentials == null) {
      throw StateError('Sesión no iniciada');
    }
    return credentials;
  }
}
