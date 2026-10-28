import '../../domain/entities/category.dart';
import '../../domain/entities/channel.dart';
import '../../domain/entities/content_type.dart';
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
import '../datasources/local/auth_store.dart';
import 'm3u_repository.dart';
import 'xtream_repository.dart';

/// Repositorio multi-fuente que delega en el repositorio concreto (Xtream o
/// M3U) según la configuración pedida en [login] y la sesión activa para el
/// resto de operaciones.
///
/// Permite cambiar de fuente en el login sin que la aplicación necesite
/// conocer la sesión guardada: `main.dart` construye este único repositorio y
/// todos los blocs lo usan de forma transparente.
class MultiSourceRepository implements IptvRepository {
  MultiSourceRepository({
    required this.xtream,
    required this.m3u,
    required this.authStore,
  });

  final XtreamRepository xtream;
  final M3uRepository m3u;
  final AuthStore authStore;

  /// Repositorio concreto de la sesión activa según la fuente guardada.
  Future<IptvRepository> _active() async {
    final StoredCredentials? stored = await authStore.read();
    return stored?.sourceType == IptvSourceType.m3u ? m3u : xtream;
  }

  Future<IptvRepository> _forConfig(IptvAuthConfig config) async {
    return config.sourceType == IptvSourceType.m3u ? m3u : xtream;
  }

  @override
  Future<UserAccount> login(
    IptvAuthConfig config, {
    bool activate = true,
  }) async {
    final IptvRepository repo = await _forConfig(config);
    return repo.login(config, activate: activate);
  }

  @override
  Future<UserAccount?> restoreSession() =>
      _active().then((r) => r.restoreSession());

  @override
  Future<void> logout() async {
    // Ambos repos limpian sus credenciales (solo está activo el de la sesión).
    await xtream.logout();
    await m3u.logout();
  }

  @override
  Future<List<Category>> fetchLiveCategories() =>
      _active().then((r) => r.fetchLiveCategories());

  @override
  Future<List<Channel>> fetchLiveChannels({int? categoryId}) =>
      _active().then((r) => r.fetchLiveChannels(categoryId: categoryId));

  @override
  Future<String> buildStreamUrl(Channel channel) =>
      _active().then((r) => r.buildStreamUrl(channel));

  @override
  Future<String?> buildCatchupUrl({
    required int streamId,
    required bool hasArchive,
    int? archiveDurationDays,
    required EpgEntry program,
  }) => _active().then(
    (r) => r.buildCatchupUrl(
      streamId: streamId,
      hasArchive: hasArchive,
      archiveDurationDays: archiveDurationDays,
      program: program,
    ),
  );

  @override
  Future<List<Category>> fetchVodCategories() =>
      _active().then((r) => r.fetchVodCategories());

  @override
  Future<List<Movie>> fetchVodStreams({int? categoryId}) =>
      _active().then((r) => r.fetchVodStreams(categoryId: categoryId));

  @override
  Future<String> buildVodStreamUrl(Movie movie) =>
      _active().then((r) => r.buildVodStreamUrl(movie));

  @override
  Future<List<Category>> fetchSeriesCategories() =>
      _active().then((r) => r.fetchSeriesCategories());

  @override
  Future<List<Series>> fetchSeries({int? categoryId}) =>
      _active().then((r) => r.fetchSeries(categoryId: categoryId));

  @override
  Future<SeriesInfo> fetchSeriesInfo(int seriesId) =>
      _active().then((r) => r.fetchSeriesInfo(seriesId));

  @override
  Future<String> buildEpisodeStreamUrl(Episode episode) =>
      _active().then((r) => r.buildEpisodeStreamUrl(episode));

  @override
  Future<List<EpgEntry>> fetchShortEpg(int streamId) =>
      _active().then((r) => r.fetchShortEpg(streamId));

  @override
  Future<List<EpgEntry>> fetchFullEpg(int streamId) =>
      _active().then((r) => r.fetchFullEpg(streamId));

  @override
  Future<void> addToFavorite(FavoriteItem item) =>
      _active().then((r) => r.addToFavorite(item));

  @override
  Future<void> removeFromFavorite(int contentId, ContentType type) =>
      _active().then((r) => r.removeFromFavorite(contentId, type));

  @override
  Future<bool> isFavorite(int contentId, ContentType type) =>
      _active().then((r) => r.isFavorite(contentId, type));

  @override
  Future<List<FavoriteItem>> getFavorites() =>
      _active().then((r) => r.getFavorites());

  @override
  Future<void> addToHistory(HistoryItem item) =>
      _active().then((r) => r.addToHistory(item));

  @override
  Future<List<HistoryItem>> getHistory() =>
      _active().then((r) => r.getHistory());

  @override
  Future<void> clearHistory() => _active().then((r) => r.clearHistory());

  @override
  Future<void> removeFromHistory(int contentId, ContentType type) =>
      _active().then((r) => r.removeFromHistory(contentId, type));

  @override
  Future<void> refreshCatalog() => _active().then((r) => r.refreshCatalog());

  @override
  Future<void> clearCatalogCache() =>
      _active().then((r) => r.clearCatalogCache());
}
