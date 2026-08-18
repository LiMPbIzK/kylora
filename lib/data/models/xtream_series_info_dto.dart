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

    final String? plot = _str(info['plot']);
    final String? genre = _join(info['genre']);
    final String? director = _str(info['director']);
    final String? cast = _join(info['cast']);
    final String? releaseDate = _str(info['releaseDate']);
    final String? rating = _str(info['rating']);
    final String? backdropPath = _str(info['backdrop_path']);

    final List<Season> seasons = _parseSeasons(json);

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

  /// Convierte cualquier valor JSON (string o número) a `String?`.
  static String? _str(dynamic value) => value?.toString();

  /// Convierte a string un valor que puede ser lista (une sus elementos).
  static String? _join(dynamic value) {
    if (value is List<dynamic>) {
      final List<String> parts = value
          .map((dynamic item) => item.toString())
          .toList();
      return parts.isEmpty ? null : parts.join(', ');
    }
    return _str(value);
  }

  /// Parsea las temporadas y sus episodios desde el bloque `episodes`.
  ///
  /// En la mayoría de servidores Xtream, el detalle trae el bloque `episodes`
  /// como un mapa `{ "<season_number>": [episodios] }`; el bloque `seasons`
  /// solo contiene metadatos. Por robustez, usamos `episodes` con fallback a
  /// `seasons` (algunas fuentes antiguas incluyen ahí los episodios).
  static List<Season> _parseSeasons(Map<String, dynamic> json) {
    final dynamic rawMap = json['episodes'] ?? json['seasons'];
    final Map<String, dynamic> map =
        rawMap is Map<String, dynamic> ? rawMap : <String, dynamic>{};

    final List<Season> result = <Season>[];
    for (final MapEntry<String, dynamic> entry in map.entries) {
      final int? seasonNumber = int.tryParse(entry.key);
      if (seasonNumber == null) continue;

      final List<Episode> episodes = <Episode>[];
      final dynamic value = entry.value;
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

    final Map<String, dynamic> info =
        json['info'] is Map<String, dynamic>
        ? json['info'] as Map<String, dynamic>
        : <String, dynamic>{};

    final String name = _firstNonEmpty(<String?>[
      _str(json['title']),
      _str(json['name']),
    ]) ??
        '';

    final int episodeNum =
        int.tryParse(json['episode_num']?.toString() ?? '') ?? 0;

    return Episode(
      id: episodeId,
      name: name,
      episodeNumber: episodeNum,
      cover: _firstNonEmpty(<String?>[
        _str(info['movie_image']),
        _str(json['cover']),
      ]),
      releaseDate: _firstNonEmpty(<String?>[
        _str(info['releasedate']),
        _str(json['airdate']),
        _str(json['release_date']),
      ]),
      plot: _firstNonEmpty(<String?>[
        _str(info['plot']),
        _str(json['plot']),
      ]),
      duration: _firstNonEmpty(<String?>[
        _str(info['duration']),
        _str(json['duration']),
      ]),
      containerExtension: _firstNonEmpty(<String?>[
        _str(json['container_extension']),
        _str(json['ext']),
      ]),
      seasonNumber: int.tryParse(
        json['season']?.toString() ?? _str(info['season']) ?? '',
      ),
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
