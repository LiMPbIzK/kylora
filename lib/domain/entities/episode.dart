import 'package:equatable/equatable.dart';

/// Episodio de una serie.
class Episode extends Equatable {
  const Episode({
    required this.id,
    required this.name,
    required this.episodeNumber,
    this.cover,
    this.releaseDate,
    this.plot,
    this.duration,
    this.containerExtension,
    this.seasonNumber,
  });

  /// Identificador del stream del episodio en la fuente.
  final int id;

  /// Título del episodio.
  final String name;

  /// Número del episodio dentro de la temporada.
  final int episodeNumber;

  /// URL de la miniatura del episodio.
  final String? cover;

  /// Fecha de emisión original.
  final String? releaseDate;

  /// Sinopsis del episodio.
  final String? plot;

  /// Duración del episodio.
  final String? duration;

  /// Extensión del contenedor (p. ej. `mp4`).
  final String? containerExtension;

  /// Número de temporada al que pertenece.
  final int? seasonNumber;

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    episodeNumber,
    cover,
    releaseDate,
    plot,
    duration,
    containerExtension,
    seasonNumber,
  ];
}
