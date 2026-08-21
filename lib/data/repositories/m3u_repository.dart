import 'package:drift/drift.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/m3u_parser.dart';
import '../../core/utils/xmltv_parser.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/channel.dart';
import '../../domain/entities/content_type.dart' as domain;
import '../../domain/entities/epg.dart';
import '../../domain/entities/episode.dart';
import '../../domain/entities/favorite_item.dart';
import '../../domain/entities/history_item.dart';
import '../../domain/entities/iptv_auth_config.dart';
import '../../domain/entities/iptv_source_type.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/series.dart';
import '../../domain/entities/series_info.dart';
import '../../domain/entities/user_account.dart';
import '../../domain/repositories/iptv_repository.dart';
import '../datasources/local/app_database.dart';
import '../datasources/local/auth_store.dart';
import '../datasources/local/live_cache_store.dart';
import '../datasources/remote/m3u_downloader.dart';

/// Implementación M3U/XMLTV del contrato [IptvRepository].
///
/// Descarga y parsea la lista M3U (y la guía XMLTV opcional) y persiste el
/// catálogo en directo en la caché local. Solo re-descarga al iniciar sesión
/// o restaurar; el resto de lecturas usan la caché.
class M3uRepository implements IptvRepository {
  M3uRepository(
    this._downloader,
    this._authStore,
    this._db, {
    LiveCacheStore? cache,
  }) : _cache = cache ?? LiveCacheStore(_db);

  final M3uDownloader _downloader;
  final AuthStore _authStore;
  final AppDatabase _db;
  final LiveCacheStore _cache;

  /// Catálogo en directo en memoria (se puebla al login/restaurar).
  List<M3uEntry>? _entries;

  /// Guía EPG parseada (por tvg-id del canal).
  Map<String, List<EpgEntry>> _epgByChannel = <String, List<EpgEntry>>{};

  /// Categorías derivadas de los grupos M3U.
  List<Category> _categories = <Category>[];

  @override
  Future<UserAccount> login(IptvAuthConfig config) async {
    final M3uAuthConfig m3u = config as M3uAuthConfig;
    await _loadPlaylist(m3u.m3uUrl, m3u.xmltvUrl);
    await _cache.replaceLiveContent(
      categories: _categories,
      channels: _buildChannels(),
    );
    await _authStore.write(
      StoredCredentials(
        serverUrl: m3u.m3uUrl,
        username: '',
        password: '',
        sourceType: config.sourceType,
        m3uUrl: m3u.m3uUrl,
        xmltvUrl: m3u.xmltvUrl,
      ),
    );
    return UserAccount(
      serverUrl: m3u.m3uUrl,
      username: m3u.displayName ?? m3u.m3uUrl,
      password: '',
      status: 'Active',
      sourceType: config.sourceType,
    );
  }

  @override
  Future<UserAccount?> restoreSession() async {
    final StoredCredentials? stored = await _authStore.read();
    if (stored == null || stored.sourceType != IptvSourceType.m3u) {
      return null;
    }
    try {
      await _loadPlaylist(stored.m3uUrl ?? '', stored.xmltvUrl);
      await _cache.replaceLiveContent(
        categories: _categories,
        channels: _buildChannels(),
      );
      return UserAccount(
        serverUrl: stored.serverUrl,
        username: stored.username,
        password: stored.password,
        status: 'Active',
        sourceType: stored.sourceType,
      );
    } on M3uNetworkException {
      await _authStore.clear();
      return null;
    } on M3uParseException {
      await _authStore.clear();
      return null;
    }
  }

  @override
  Future<void> logout() => _authStore.clear();

  @override
  Future<List<Category>> fetchLiveCategories() async {
    final List<Category> cached = await _cache.getCategories();
    if (cached.isNotEmpty) return cached;
    return _categories;
  }

  @override
  Future<List<Channel>> fetchLiveChannels({int? categoryId}) async {
    final List<Channel> cached = await _cache.getChannels(
      categoryId: categoryId,
    );
    if (cached.isNotEmpty) return cached;
    final List<Channel> all = _buildChannels();
    if (categoryId == null) return all;
    return all
        .where((Channel channel) => channel.categoryId == categoryId)
        .toList();
  }

  @override
  Future<String> buildStreamUrl(Channel channel) async {
    final M3uEntry? entry = _findEntryByName(channel.name);
    return entry?.url ?? '';
  }

  @override
  Future<List<Category>> fetchVodCategories() async => const <Category>[];

  @override
  Future<List<Movie>> fetchVodStreams({int? categoryId}) async =>
      const <Movie>[];

  @override
  Future<String> buildVodStreamUrl(Movie movie) async => '';

  @override
  Future<List<Category>> fetchSeriesCategories() async => const <Category>[];

  @override
  Future<List<Series>> fetchSeries({int? categoryId}) async =>
      const <Series>[];

  @override
  Future<SeriesInfo> fetchSeriesInfo(int seriesId) async {
    throw UnsupportedError('M3U no soporta series');
  }

  @override
  Future<String> buildEpisodeStreamUrl(Episode episode) async => '';

  @override
  Future<List<EpgEntry>> fetchShortEpg(int streamId) async {
    final Channel? channel = await _channelByStreamId(streamId);
    if (channel == null) return <EpgEntry>[];
    return _epgForChannel(channel, limit: 2);
  }

  @override
  Future<List<EpgEntry>> fetchFullEpg(int streamId) async {
    final Channel? channel = await _channelByStreamId(streamId);
    if (channel == null) return <EpgEntry>[];
    return _epgForChannel(channel);
  }

  @override
  Future<void> addToFavorite(FavoriteItem item) async {
    await _db.into(_db.favorites).insert(
      FavoritesCompanion.insert(
        contentId: item.contentId,
        contentType: item.contentType.name,
        name: item.name,
        logo: Value(item.logo),
        addedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> removeFromFavorite(int contentId, domain.ContentType type) async {
    await (_db.delete(_db.favorites)
          ..where((f) => f.contentId.equals(contentId))
          ..where((f) => f.contentType.equals(type.name)))
        .go();
  }

  @override
  Future<bool> isFavorite(int contentId, domain.ContentType type) async {
    final List<Favorite> rows = await (_db.select(_db.favorites)
          ..where((f) => f.contentId.equals(contentId))
          ..where((f) => f.contentType.equals(type.name)))
        .get();
    return rows.isNotEmpty;
  }

  @override
  Future<List<FavoriteItem>> getFavorites() async {
    final List<Favorite> rows = await _db.select(_db.favorites).get();
    return rows
        .map((Favorite row) => FavoriteItem(
              contentId: row.contentId,
              contentType: _parseContentType(row.contentType),
              name: row.name,
              logo: row.logo,
            ))
        .toList();
  }

  @override
  Future<void> addToHistory(HistoryItem item) async {
    await _db.into(_db.history).insert(
      HistoryCompanion.insert(
        contentId: item.contentId,
        contentType: item.contentType.name,
        name: item.name,
        logo: Value(item.logo),
        watchedAt: item.watchedAt,
        position: Value(item.position),
        duration: Value(item.duration),
      ),
    );
  }

  @override
  Future<List<HistoryItem>> getHistory() async {
    final List<HistoryData> rows = await (_db.select(_db.history)
          ..orderBy([(t) => OrderingTerm.desc(t.watchedAt)]))
        .get();
    return rows
        .map((HistoryData row) => HistoryItem(
              contentId: row.contentId,
              contentType: _parseContentType(row.contentType),
              name: row.name,
              logo: row.logo,
              watchedAt: row.watchedAt,
              position: row.position,
              duration: row.duration,
            ))
        .toList();
  }

  /// Descarga y parsea la lista M3U (y la guía XMLTV opcional).
  Future<void> _loadPlaylist(String m3uUrl, String? xmltvUrl) async {
    final String content = await _downloader.download(
      m3uUrl,
      userAgent: AppConstants.userAgent,
    );
    if (content.isEmpty) {
      throw const M3uParseException('La lista M3U está vacía');
    }
    final List<M3uEntry> entries = await parseM3uInIsolate(content);
    if (entries.isEmpty) {
      throw const M3uParseException('No se encontraron canales en la lista M3U');
    }
    _entries = entries;
    _buildCategories();

    if (xmltvUrl != null && xmltvUrl.isNotEmpty) {
      try {
        final String xml = await _downloader.download(
          xmltvUrl,
          userAgent: AppConstants.userAgent,
        );
        _epgByChannel = await parseXmltvGroupedInIsolate(xml);
      } on M3uNetworkException {
        _epgByChannel = <String, List<EpgEntry>>{};
      } on M3uParseException {
        _epgByChannel = <String, List<EpgEntry>>{};
      } catch (_) {
        _epgByChannel = <String, List<EpgEntry>>{};
      }
    } else {
      _epgByChannel = <String, List<EpgEntry>>{};
    }
  }

  /// Construye las categorías a partir de los grupos de la lista M3U.
  void _buildCategories() {
    final Map<String, int> seen = <String, int>{};
    final List<Category> result = <Category>[];
    int nextId = 1;
    for (final M3uEntry entry in _entries!) {
      final String group = (entry.groupTitle?.isEmpty ?? true)
          ? 'Ungrouped'
          : entry.groupTitle!;
      if (!seen.containsKey(group)) {
        seen[group] = nextId;
        result.add(Category(id: nextId, name: group));
        nextId++;
      }
    }
    _categories = result;
  }

  /// Construye los canales a partir de las entradas M3U.
  List<Channel> _buildChannels() {
    final List<Channel> result = <Channel>[];
    final Map<String, int> groupIds = <String, int>{};
    for (final Category category in _categories) {
      groupIds[category.name] = category.id;
    }
    int streamId = 1;
    int number = 1;
    for (final M3uEntry entry in _entries ?? const <M3uEntry>[]) {
      final String group = (entry.groupTitle?.isEmpty ?? true)
          ? 'Ungrouped'
          : entry.groupTitle!;
      final String name = entry.tvgName?.isNotEmpty == true
          ? entry.tvgName!
          : entry.name;
      result.add(
        Channel(
          id: streamId,
          name: name,
          categoryId: groupIds[group] ?? 0,
          number: entry.duration < 0 ? number : null,
          logo: entry.logo,
          epgChannelId: entry.tvgId,
        ),
      );
      streamId++;
      number++;
    }
    return result;
  }

  M3uEntry? _findEntryByName(String name) {
    for (final M3uEntry entry in _entries ?? const <M3uEntry>[]) {
      final String n = entry.tvgName?.isNotEmpty == true
          ? entry.tvgName!
          : entry.name;
      if (n == name) return entry;
    }
    return null;
  }

  Future<Channel?> _channelByStreamId(int streamId) async {
    final List<Channel> all = await fetchLiveChannels();
    for (final Channel channel in all) {
      if (channel.id == streamId) return channel;
    }
    return null;
  }

  List<EpgEntry> _epgForChannel(Channel channel, {int? limit}) {
    final String? key = channel.epgChannelId;
    if (key == null) return <EpgEntry>[];
    final List<EpgEntry> entries = _epgByChannel[key] ?? <EpgEntry>[];
    if (limit == null) return entries;
    return entries.take(limit).toList();
  }

  domain.ContentType _parseContentType(String value) {
    return switch (value) {
      'live' => domain.ContentType.live,
      'vod' => domain.ContentType.vod,
      'series' => domain.ContentType.series,
      _ => domain.ContentType.live,
    };
  }
}
