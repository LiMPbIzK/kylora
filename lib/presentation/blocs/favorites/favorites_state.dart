import 'package:equatable/equatable.dart';

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
  const FavoritesLoaded(this.items);

  final List<FavoriteItem> items;

  @override
  List<Object?> get props => <Object?>[items];
}

/// Error al cargar favoritos.
final class FavoritesFailure extends FavoritesState {
  const FavoritesFailure(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
