import 'package:equatable/equatable.dart';

import '../../../domain/entities/category.dart';
import '../../../domain/entities/movie.dart';

/// Estados del catálogo de películas (VOD).
sealed class VodState extends Equatable {
  const VodState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Cargando categorías y películas.
final class VodLoading extends VodState {
  const VodLoading();
}

/// Catálogo cargado. [movies] son las películas de la categoría seleccionada.
final class VodLoaded extends VodState {
  const VodLoaded({
    required this.categories,
    required this.selectedCategoryId,
    required this.movies,
  });

  final List<Category> categories;
  final int? selectedCategoryId;
  final List<Movie> movies;

  bool get isAllSelected => selectedCategoryId == null;

  @override
  List<Object?> get props => <Object?>[categories, selectedCategoryId, movies];
}

/// Error al cargar el catálogo de películas.
final class VodFailure extends VodState {
  const VodFailure(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
