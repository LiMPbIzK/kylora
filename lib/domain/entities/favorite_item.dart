import 'package:equatable/equatable.dart';

import 'content_type.dart';

/// Elemento favorito del usuario.
class FavoriteItem extends Equatable {
  const FavoriteItem({
    required this.contentId,
    required this.contentType,
    required this.name,
    this.logo,
  });

  final int contentId;
  final ContentType contentType;
  final String name;
  final String? logo;

  @override
  List<Object?> get props => <Object?>[contentId, contentType, name, logo];
}
