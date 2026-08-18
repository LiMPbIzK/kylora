import 'package:equatable/equatable.dart';

/// Eventos del catálogo de canales en directo.
sealed class LiveEvent extends Equatable {
  const LiveEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Carga inicial de categorías y canales.
final class LiveStarted extends LiveEvent {
  const LiveStarted();
}

/// Selecciona una categoría (null = todas).
final class LiveCategorySelected extends LiveEvent {
  const LiveCategorySelected(this.categoryId);

  final int? categoryId;

  @override
  List<Object?> get props => <Object?>[categoryId];
}
