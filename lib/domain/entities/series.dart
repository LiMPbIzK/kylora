import 'package:equatable/equatable.dart';

/// Serie de una fuente IPTV.
class Series extends Equatable {
  const Series({
    required this.id,
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

  /// Identificador único de la serie en la fuente.
  final int id;

  /// Título de la serie.
  final String name;

  /// Número de stream.
  final int? number;

  /// Número de temporada.
  final int? season;

  /// URL del póster.
  final String? cover;

  /// Sinopsis.
  final String? plot;

  /// Reparto como texto separado por comas.
  final String? cast;

  /// Director.
  final String? director;

  /// Géneros.
  final String? genre;

  /// Fecha de estreno.
  final String? releaseDate;

  /// Calificación de la fuente (0-10).
  final String? rating;

  /// Calificación de la fuente (0-5).
  final String? rating5Based;

  /// Imagen de fondo de portada.
  final String? backdropPath;

  /// ID del trailer de YouTube.
  final String? youtubeTrailer;

  /// Duración por episodio.
  final String? episodeRunTime;

  /// Categoría a la que pertenece la serie.
  final int? categoryId;

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    number,
    season,
    cover,
    plot,
    cast,
    director,
    genre,
    releaseDate,
    rating,
    rating5Based,
    backdropPath,
    youtubeTrailer,
    episodeRunTime,
    categoryId,
  ];
}
