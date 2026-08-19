import '../entities/category.dart';
import '../entities/channel.dart';
import '../entities/content_type.dart';
import '../entities/epg.dart';
import '../entities/episode.dart';
import '../entities/favorite_item.dart';
import '../entities/history_item.dart';
import '../entities/movie.dart';
import '../entities/series.dart';
import '../entities/series_info.dart';
import '../entities/user_account.dart';

/// Contrato de repositorio agnóstico de fuente IPTV.
/// Tanto Xtream como M3U deben implementarlo.
abstract interface class IptvRepository {
  /// Autentica contra el proveedor y persiste las credenciales.
  Future<UserAccount> login({
    required String serverUrl,
    required String username,
    required String password,
  });

  /// Restaura la sesión guardada sin requerir credenciales.
  Future<UserAccount?> restoreSession();

  /// Cierra sesión y borra credenciales almacenadas.
  Future<void> logout();

  /// Categorías de canales en directo.
  Future<List<Category>> fetchLiveCategories();

  /// Canales en directo. Si [categoryId] es nulo, devuelve todos los canales.
  Future<List<Channel>> fetchLiveChannels({int? categoryId});

  /// Construye la URL de reproducción de un canal en directo.
  Future<String> buildStreamUrl(Channel channel);

  /// Categorías de películas (VOD).
  Future<List<Category>> fetchVodCategories();

  /// Películas (VOD). Si [categoryId] es nulo, devuelve todas.
  Future<List<Movie>> fetchVodStreams({int? categoryId});

  /// Construye la URL de reproducción de una película (VOD).
  Future<String> buildVodStreamUrl(Movie movie);

  /// Categorías de series.
  Future<List<Category>> fetchSeriesCategories();

  /// Series. Si [categoryId] es nulo, devuelve todas.
  Future<List<Series>> fetchSeries({int? categoryId});

  /// Información detallada de una serie con sus temporadas y episodios.
  Future<SeriesInfo> fetchSeriesInfo(int seriesId);

  /// Construye la URL de reproducción de un episodio de una serie.
  Future<String> buildEpisodeStreamUrl(Episode episode);

  /// Obtiene el EPG corto (ahora/siguiente) de un canal en directo.
  Future<List<EpgEntry>> fetchShortEpg(int streamId);

  /// Obtiene la programación EPG completa de un canal en directo.
  Future<List<EpgEntry>> fetchFullEpg(int streamId);

  /// Añade un elemento a favoritos.
  Future<void> addToFavorite(FavoriteItem item);

  /// Elimina un elemento de favoritos.
  Future<void> removeFromFavorite(int contentId, ContentType type);

  /// Comprueba si un elemento está en favoritos.
  Future<bool> isFavorite(int contentId, ContentType type);

  /// Obtiene todos los favoritos del usuario.
  Future<List<FavoriteItem>> getFavorites();

  /// Registra una entrada en el historial de reproducción.
  Future<void> addToHistory(HistoryItem item);

  /// Obtiene el historial de reproducción ordenado por fecha (más reciente primero).
  Future<List<HistoryItem>> getHistory();
}
