import 'package:equatable/equatable.dart';

import '../../../domain/entities/series.dart';

/// Eventos del catálogo y detalle de series.
sealed class SeriesEvent extends Equatable {
  const SeriesEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Carga inicial de categorías y series.
final class SeriesStarted extends SeriesEvent {
  const SeriesStarted();
}

/// Selecciona una categoría (null = todas).
final class SeriesCategorySelected extends SeriesEvent {
  const SeriesCategorySelected(this.categoryId);

  final int? categoryId;

  @override
  List<Object?> get props => <Object?>[categoryId];
}

/// Solicita el detalle (temporadas y episodios) de [series].
final class SeriesDetailRequested extends SeriesEvent {
  const SeriesDetailRequested(this.series);

  final Series series;

  @override
  List<Object?> get props => <Object?>[series];
}

/// Vuelve al catálogo desde el detalle.
final class SeriesDetailClosed extends SeriesEvent {
  const SeriesDetailClosed();
}
