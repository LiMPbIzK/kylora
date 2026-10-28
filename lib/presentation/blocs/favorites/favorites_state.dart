import 'package:equatable/equatable.dart';

import '../../../domain/entities/favorite_channel_group.dart';
import '../../../domain/entities/favorite_item.dart';

/// Estados del bloc de favoritos.
sealed class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Cargando favoritos.
final class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

/// Favoritos cargados.
final class FavoritesLoaded extends FavoritesState {
  const FavoritesLoaded(
    this.items, {
    this.groups = const <FavoriteChannelGroup>[],
  });

  final List<FavoriteItem> items;
  final List<FavoriteChannelGroup> groups;

  @override
  List<Object?> get props => <Object?>[items, groups];
}

/// Error al cargar favoritos.
final class FavoritesFailure extends FavoritesState {
  const FavoritesFailure(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
