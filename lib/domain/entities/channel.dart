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

  @override
  List<Object?> get props => [id, name, categoryId, number, logo, epgChannelId];
}
