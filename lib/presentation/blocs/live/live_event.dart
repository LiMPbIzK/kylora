import 'package:equatable/equatable.dart';

/// Eventos del catálogo de canales en directo.
sealed class LiveEvent extends Equatable {
  const LiveEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Carga inicial de categorías y canales.
///
/// [radio] indica que el catálogo es la sección Radio (solo categorías de
/// radio); por defecto carga la TV.
final class LiveStarted extends LiveEvent {
  const LiveStarted({this.radio = false});

  final bool radio;

  @override
  List<Object?> get props => <Object?>[radio];
}

/// Selecciona una categoría (null = todas).
final class LiveCategorySelected extends LiveEvent {
  const LiveCategorySelected(this.categoryId);

  final int? categoryId;

  @override
  List<Object?> get props => <Object?>[categoryId];
}

/// Cambia el texto de búsqueda en la lista de canales.
final class LiveSearchChanged extends LiveEvent {
  const LiveSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => <Object?>[query];
}

/// Fuerza la recarga del catálogo desde el proveedor.
final class LiveRefreshRequested extends LiveEvent {
  const LiveRefreshRequested();
}
