import '../../domain/entities/series.dart';

/// DTO de una serie devuelta por `get_series.php`.
class XtreamSeriesDto {
  const XtreamSeriesDto({
    required this.seriesId,
    required this.name,
    this.number,
    this.season,
    this.cover,
    this.plot,
    this.cast,
    this.director,
    this.genre,
    this.releaseDate,
    this.rating,
    this.rating5Based,
    this.backdropPath,
    this.youtubeTrailer,
    this.episodeRunTime,
    this.categoryId,
  });

  final int seriesId;
  final String name;
  final int? number;
  final int? season;
  final String? cover;
  final String? plot;
  final String? cast;
  final String? director;
  final String? genre;
  final String? releaseDate;
  final String? rating;
  final String? rating5Based;
  final String? backdropPath;
  final String? youtubeTrailer;
  final String? episodeRunTime;
  final int? categoryId;

  factory XtreamSeriesDto.fromJson(Map<String, dynamic> json) {
    return XtreamSeriesDto(
      seriesId: int.tryParse(json['series_id']?.toString() ?? '') ?? 0,
      name: json['name'] as String? ?? '',
      number: int.tryParse(json['num']?.toString() ?? ''),
      season: int.tryParse(json['season']?.toString() ?? ''),
      cover: json['cover'] as String?,
      plot: json['plot'] as String?,
      cast: json['cast'] as String?,
      director: json['director'] as String?,
      genre: json['genre'] as String?,
      releaseDate: json['releaseDate'] as String?,
      rating: json['rating'] as String?,
      rating5Based: json['rating_5based'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      youtubeTrailer: json['youtube_trailer'] as String?,
      episodeRunTime: json['episode_run_time'] as String?,
      categoryId: int.tryParse(json['category_id']?.toString() ?? ''),
    );
  }

  Series toEntity() => Series(
    id: seriesId,
    name: name,
    number: number,
    season: season,
    cover: cover,
    plot: plot,
    cast: cast,
    director: director,
    genre: genre,
    releaseDate: releaseDate,
    rating: rating,
    rating5Based: rating5Based,
    backdropPath: backdropPath,
    youtubeTrailer: youtubeTrailer,
    episodeRunTime: episodeRunTime,
    categoryId: categoryId,
  );
}
