import 'package:equatable/equatable.dart';

/// Eventos del catálogo de películas (VOD).
sealed class VodEvent extends Equatable {
  const VodEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Carga inicial de categorías y películas.
final class VodStarted extends VodEvent {
  const VodStarted();
}

/// Selecciona una categoría (null = todas).
final class VodCategorySelected extends VodEvent {
  const VodCategorySelected(this.categoryId);

  final int? categoryId;

  @override
  List<Object?> get props => <Object?>[categoryId];
}

/// Cambia el texto de búsqueda. Filtra las películas en memoria.
final class VodSearchChanged extends VodEvent {
  const VodSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => <Object?>[query];
}
