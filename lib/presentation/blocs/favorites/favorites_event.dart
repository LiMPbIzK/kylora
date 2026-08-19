import 'package:equatable/equatable.dart';

/// Eventos del bloc de favoritos.
sealed class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Carga la lista de favoritos.
final class FavoritesStarted extends FavoritesEvent {
  const FavoritesStarted();
}

/// Añade o quita un elemento de favoritos (toggle).
final class FavoritesToggled extends FavoritesEvent {
  const FavoritesToggled(this.contentId, this.contentType, this.name, this.logo);

  final int contentId;
  final String contentType;
  final String name;
  final String? logo;

  @override
  List<Object?> get props => <Object?>[contentId, contentType, name, logo];
}
