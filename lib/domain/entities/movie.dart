import 'package:equatable/equatable.dart';

/// Película de una fuente IPTV (VOD).
class Movie extends Equatable {
  const Movie({
    required this.id,
    required this.name,
    required this.categoryId,
    this.number,
    this.streamType,
    this.streamIcon,
    this.rating,
    this.rating5Based,
    this.added,
    this.containerExtension,
    this.customSkin,
    this.directSource,
  });

  /// Identificador único del stream VOD en la fuente.
  final int id;

  final String name;

  /// Categoría a la que pertenece la película.
  final int categoryId;

  /// Número de stream opcional.
  final int? number;

  /// Tipo de stream (p. ej. `movie`).
  final String? streamType;

  /// URL del póster de la película.
  final String? streamIcon;

  /// Calificación de la fuente (0-10).
  final String? rating;

  /// Calificación de la fuente (0-5), con género.
  final String? rating5Based;

  /// Fecha de alta en la fuente.
  final String? added;

  /// Extensión del contenedor (p. ej. `mp4`, `mkv`).
  final String? containerExtension;

  /// Skin personalizado de la fuente.
  final String? customSkin;

  /// URL directa del stream, si la proporciona la fuente.
  final String? directSource;

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    categoryId,
    number,
    streamType,
    streamIcon,
    rating,
    rating5Based,
    added,
    containerExtension,
    customSkin,
    directSource,
  ];
}
