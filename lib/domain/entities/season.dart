import 'package:equatable/equatable.dart';

import 'episode.dart';

/// Temporada de una serie con sus episodios.
class Season extends Equatable {
  const Season({required this.number, required this.episodes});

  /// Número de temporada.
  final int number;

  /// Episodios de la temporada, ordenados por número.
  final List<Episode> episodes;

  @override
  List<Object?> get props => <Object?>[number, episodes];
}
