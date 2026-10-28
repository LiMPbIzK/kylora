import 'package:equatable/equatable.dart';

/// Canal de televisión en directo de una fuente IPTV.
class Channel extends Equatable {
  const Channel({
    required this.id,
    required this.name,
    required this.categoryId,
    this.number,
    this.logo,
    this.epgChannelId,
    this.hasArchive = false,
    this.archiveDurationDays,
  });

  /// Identificador único del stream en la fuente.
  final int id;

  final String name;

  /// Categoría a la que pertenece el canal.
  final int categoryId;

  /// Número de canal opcional según la fuente.
  final int? number;

  /// URL del logotipo del canal.
  final String? logo;

  /// Identificador de canal para el EPG (XMLTV).
  final String? epgChannelId;

  /// El proveedor ofrece catch-up/timeshift para este canal.
  final bool hasArchive;

  /// Días de archivo disponibles según el proveedor (si se conocen).
  final int? archiveDurationDays;

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    categoryId,
    number,
    logo,
    epgChannelId,
    hasArchive,
    archiveDurationDays,
  ];
}
