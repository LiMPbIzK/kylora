import 'package:equatable/equatable.dart';

import 'season.dart';

/// Información detallada de una serie, incluyendo temporadas y episodios.
class SeriesInfo extends Equatable {
  const SeriesInfo({
    required this.seriesId,
    required this.seasons,
    this.plot,
    this.genre,
    this.director,
    this.cast,
    this.releaseDate,
    this.rating,
    this.backdropPath,
  });

  /// Identificador de la serie.
  final int seriesId;

  /// Temporadas de la serie.
  final List<Season> seasons;

  /// Sinopsis completa.
  final String? plot;

  /// Géneros.
  final String? genre;

  /// Director.
  final String? director;

  /// Reparto.
  final String? cast;

  /// Fecha de estreno.
  final String? releaseDate;

  /// Calificación.
  final String? rating;

  /// Imagen de portada de fondo.
  final String? backdropPath;

  @override
  List<Object?> get props => <Object?>[
    seriesId,
    seasons,
    plot,
    genre,
    director,
    cast,
    releaseDate,
    rating,
    backdropPath,
  ];
}
