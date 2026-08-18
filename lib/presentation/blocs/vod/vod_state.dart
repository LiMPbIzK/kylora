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

/// Catálogo cargado. [movies] son las películas de la categoría seleccionada
/// que coinciden con [query].
final class VodLoaded extends VodState {
  const VodLoaded({
    required this.categories,
    required this.selectedCategoryId,
    required this.query,
    required this.movies,
  });

  final List<Category> categories;
  final int? selectedCategoryId;
  final String query;
  final List<Movie> movies;

  bool get isAllSelected => selectedCategoryId == null;
  bool get isSearching => query.trim().isNotEmpty;

  @override
  List<Object?> get props => <Object?>[
    categories,
    selectedCategoryId,
    query,
    movies,
  ];
}

/// Error al cargar el catálogo de películas.
final class VodFailure extends VodState {
  const VodFailure(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
