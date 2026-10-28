import 'package:equatable/equatable.dart';

import '../../../domain/entities/favorite_channel_group.dart';

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
  const FavoritesToggled(
    this.contentId,
    this.contentType,
    this.name,
    this.logo,
  );

  final int contentId;
  final String contentType;
  final String name;
  final String? logo;

  @override
  List<Object?> get props => <Object?>[contentId, contentType, name, logo];
}

/// Añade o quita un grupo/categoría de canales de favoritos.
final class FavoriteGroupToggled extends FavoritesEvent {
  const FavoriteGroupToggled(this.group);

  final FavoriteChannelGroup group;

  @override
  List<Object?> get props => <Object?>[group];
}
