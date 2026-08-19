import '../../domain/entities/category.dart';
import '../../domain/entities/channel.dart';
import '../../domain/entities/epg.dart';
import '../../domain/entities/episode.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/series.dart';
import '../../domain/entities/series_info.dart';
import '../../domain/entities/user_account.dart';
import '../../domain/repositories/iptv_repository.dart';
import '../datasources/local/app_database.dart';
import '../datasources/local/auth_store.dart';
import '../datasources/local/live_cache_store.dart';
import '../datasources/remote/xtream_api_client.dart';
import '../models/xtream_category_dto.dart';
import '../models/xtream_series_dto.dart';
import '../models/xtream_series_info_dto.dart';
import '../models/xtream_stream_dto.dart';
import '../models/xtream_user_info_dto.dart';
import '../models/xtream_vod_stream_dto.dart';

/// Implementación Xtream del contrato [IptvRepository].
class XtreamRepository implements IptvRepository {
  XtreamRepository(this._apiClient, this._authStore, {LiveCacheStore? cache})
    : _cache = cache ?? LiveCacheStore(AppDatabase());

  final XtreamApiClient _apiClient;
  final AuthStore _authStore;
  final LiveCacheStore _cache;

  @override
  Future<UserAccount> login({
    required String serverUrl,
    required String username,
    required String password,
  }) async {
    final XtreamAuthResponse response = await _apiClient.authenticate(
      serverUrl: serverUrl,
      username: username,
      password: password,
    );
    final XtreamUserInfoDto info = response.userInfo;
    final UserAccount account = UserAccount(
      serverUrl: serverUrl,
      username: username,
      password: password,
      status: info.status,
      expiresAt: info.expiresAt,
      maxConnections: info.maxConnections,
      activeConnections: info.activeConnections,
    );
    await _authStore.write(
      StoredCredentials(
        serverUrl: serverUrl,
        username: username,
        password: password,
      ),
    );
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
      final XtreamUserInfoDto info = response.userInfo;
      return UserAccount(
        serverUrl: credentials.serverUrl,
        username: credentials.username,
        password: credentials.password,
        status: info.status,
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
  Future<List<Category>> fetchLiveCategories() async {
    final List<Category> cached = await _cache.getCategories();
    if (cached.isNotEmpty) return cached;
    return _refreshLiveContent().then((_) => _cache.getCategories());
  }

  @override
  Future<List<Category>> fetchVodCategories() async {
    final StoredCredentials credentials = await _requireCredentials();
    final List<XtreamCategoryDto> dtos = await _apiClient.fetchVodCategories(
      serverUrl: credentials.serverUrl,
      username: credentials.username,
      password: credentials.password,
    );
    return dtos.map((XtreamCategoryDto category) => category.toEntity()).toList();
  }

  @override
  Future<List<Movie>> fetchVodStreams({int? categoryId}) async {
    final StoredCredentials credentials = await _requireCredentials();
    final List<XtreamVodStreamDto> dtos = await _apiClient.fetchVodStreams(
      serverUrl: credentials.serverUrl,
      username: credentials.username,
      password: credentials.password,
      categoryId: categoryId,
    );
    return dtos.map((XtreamVodStreamDto stream) => stream.toEntity()).toList();
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
    final List<XtreamCategoryDto> dtos = await _apiClient.fetchSeriesCategories(
      serverUrl: credentials.serverUrl,
      username: credentials.username,
      password: credentials.password,
    );
    return dtos.map((XtreamCategoryDto category) => category.toEntity()).toList();
  }

  @override
  Future<List<Series>> fetchSeries({int? categoryId}) async {
    final StoredCredentials credentials = await _requireCredentials();
    final List<XtreamSeriesDto> dtos = await _apiClient.fetchSeries(
      serverUrl: credentials.serverUrl,
      username: credentials.username,
      password: credentials.password,
      categoryId: categoryId,
    );
    return dtos.map((XtreamSeriesDto series) => series.toEntity()).toList();
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
  Future<List<Channel>> fetchLiveChannels({int? categoryId}) async {
    final List<Channel> cached = await _cache.getChannels(
      categoryId: categoryId,
    );
    if (cached.isNotEmpty) return cached;
    await _refreshLiveContent();
    return _cache.getChannels(categoryId: categoryId);
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
    await _cache.replaceLiveContent(categories: categories, channels: channels);
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
