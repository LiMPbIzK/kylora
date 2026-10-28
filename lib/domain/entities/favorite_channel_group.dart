import 'package:equatable/equatable.dart';

/// Grupo/categoría de canales guardado como favorito.
class FavoriteChannelGroup extends Equatable {
  const FavoriteChannelGroup({
    required this.categoryId,
    required this.name,
    required this.isRadio,
    required this.addedAt,
  });

  final int categoryId;
  final String name;
  final bool isRadio;
  final DateTime addedAt;

  @override
  List<Object?> get props => <Object?>[categoryId, name, isRadio, addedAt];
}
