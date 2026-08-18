import 'package:equatable/equatable.dart';

import '../../../domain/entities/category.dart';
import '../../../domain/entities/series.dart';
import '../../../domain/entities/series_info.dart';

/// Estados del catálogo y detalle de series.
sealed class SeriesState extends Equatable {
  const SeriesState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Cargando catálogo de series.
final class SeriesLoading extends SeriesState {
  const SeriesLoading();
}

/// Catálogo cargado. [seriesList] son las series de la categoría seleccionada
/// que coinciden con [query].
final class SeriesLoaded extends SeriesState {
  const SeriesLoaded({
    required this.categories,
    required this.selectedCategoryId,
    required this.query,
    required this.seriesList,
  });

  final List<Category> categories;
  final int? selectedCategoryId;
  final String query;
  final List<Series> seriesList;

  bool get isAllSelected => selectedCategoryId == null;
  bool get isSearching => query.trim().isNotEmpty;

  @override
  List<Object?> get props => <Object?>[
    categories,
    selectedCategoryId,
    query,
    seriesList,
  ];
}

/// Error al cargar el catálogo de series.
final class SeriesFailure extends SeriesState {
  const SeriesFailure(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// Cargando el detalle de una serie.
final class SeriesDetailLoading extends SeriesState {
  const SeriesDetailLoading(this.series);

  final Series series;

  @override
  List<Object?> get props => <Object?>[series];
}

/// Detalle cargado: portada de la serie y temporadas/episodios.
final class SeriesDetailLoaded extends SeriesState {
  const SeriesDetailLoaded({required this.series, required this.info});

  final Series series;
  final SeriesInfo info;

  @override
  List<Object?> get props => <Object?>[series, info];
}

/// Error al cargar el detalle de una serie.
final class SeriesDetailFailure extends SeriesState {
  const SeriesDetailFailure(this.series, this.message);

  final Series series;
  final String message;

  @override
  List<Object?> get props => <Object?>[series, message];
}
