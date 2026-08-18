import '../../domain/entities/episode.dart';
import '../../domain/entities/season.dart';
import '../../domain/entities/series_info.dart';

/// DTO de la información detallada de una serie (`get_series_info.php`).
class XtreamSeriesInfoDto {
  const XtreamSeriesInfoDto({
    required this.seasons,
    this.plot,
    this.genre,
    this.director,
    this.cast,
    this.releaseDate,
    this.rating,
    this.backdropPath,
  });

  final List<Season> seasons;
  final String? plot;
  final String? genre;
  final String? director;
  final String? cast;
  final String? releaseDate;
  final String? rating;
  final String? backdropPath;

  factory XtreamSeriesInfoDto.fromJson(Map<String, dynamic> json) {
    final dynamic rawInfo = json['info'];
    final Map<String, dynamic> info = rawInfo is Map<String, dynamic>
        ? rawInfo
        : <String, dynamic>{};

    final String? plot = info['plot'] as String?;
    final String? genre = info['genre'] as String?;
    final String? director = info['director'] as String?;
    final String? cast = info['cast'] as String?;
    final String? releaseDate = info['releaseDate'] as String?;
    final String? rating = info['rating'] as String?;
    final String? backdropPath = info['backdrop_path'] as String?;

    final List<Season> seasons = _parseSeasons(json['seasons']);

    return XtreamSeriesInfoDto(
      seasons: seasons,
      plot: plot,
      genre: genre,
      director: director,
      cast: cast,
      releaseDate: releaseDate,
      rating: rating,
      backdropPath: backdropPath,
    );
  }

  /// Parsea las temporadas y sus episodios desde el bloque `seasons`.
  static List<Season> _parseSeasons(dynamic raw) {
    final Map<String, dynamic> seasonsMap =
        raw is Map<String, dynamic> ? raw : <String, dynamic>{};

    final List<Season> result = <Season>[];
    for (final MapEntry<String, dynamic> entry in seasonsMap.entries) {
      final int? seasonNumber = int.tryParse(entry.key);
      if (seasonNumber == null) continue;

      final dynamic value = entry.value;
      final List<Episode> episodes = <Episode>[];
      if (value is List<dynamic>) {
        for (final dynamic item in value) {
          if (item is! Map<String, dynamic>) continue;
          final Episode? episode = _parseEpisode(item);
          if (episode != null) episodes.add(episode);
        }
      }
      result.add(Season(number: seasonNumber, episodes: episodes));
    }

    result.sort((Season a, Season b) => a.number.compareTo(b.number));
    return result;
  }

  /// Parsea un episodio individual (el formato varía según la fuente).
  static Episode? _parseEpisode(Map<String, dynamic> json) {
    final dynamic id = json['id'] ?? json['episode_id'];
    final int? episodeId = int.tryParse(id?.toString() ?? '');
    if (episodeId == null) return null;

    final String name = _firstNonEmpty(<String?>[
      json['title'] as String?,
      json['name'] as String?,
    ]) ??
        '';

    final int episodeNum =
        int.tryParse(json['episode_num']?.toString() ?? '') ?? 0;

    return Episode(
      id: episodeId,
      name: name,
      episodeNumber: episodeNum,
      cover: _firstNonEmpty(<String?>[
        json['info'] is Map<String, dynamic>
            ? (json['info'] as Map<String, dynamic>)['movie_image'] as String?
            : null,
        json['cover'] as String?,
      ]),
      releaseDate: json['airdate'] as String?,
      plot: _firstNonEmpty(<String?>[
        json['info'] is Map<String, dynamic>
            ? (json['info'] as Map<String, dynamic>)['plot'] as String?
            : null,
        json['plot'] as String?,
      ]),
      duration: json['duration'] as String?,
      containerExtension: json['container_extension'] as String?,
      seasonNumber: int.tryParse(json['season']?.toString() ?? ''),
    );
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final String? value in values) {
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  SeriesInfo toEntity(int seriesId) => SeriesInfo(
    seriesId: seriesId,
    seasons: seasons,
    plot: plot,
    genre: genre,
    director: director,
    cast: cast,
    releaseDate: releaseDate,
    rating: rating,
    backdropPath: backdropPath,
  );
}
