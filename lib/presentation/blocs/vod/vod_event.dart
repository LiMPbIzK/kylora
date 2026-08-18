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
