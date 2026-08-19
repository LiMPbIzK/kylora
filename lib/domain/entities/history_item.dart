import 'package:equatable/equatable.dart';

import 'content_type.dart';

/// Entrada del historial de reproducción.
class HistoryItem extends Equatable {
  const HistoryItem({
    required this.contentId,
    required this.contentType,
    required this.name,
    required this.watchedAt,
    this.logo,
    this.position = 0,
    this.duration,
  });

  final int contentId;
  final ContentType contentType;
  final String name;
  final String? logo;
  final DateTime watchedAt;

  /// Posición en segundos donde se quedó la reproducción.
  final int position;

  /// Duración total del contenido en segundos (null para directo).
  final int? duration;

  @override
  List<Object?> get props => <Object?>[
    contentId,
    contentType,
    name,
    logo,
    watchedAt,
    position,
    duration,
  ];
}
