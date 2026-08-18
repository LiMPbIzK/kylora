import 'package:equatable/equatable.dart';

import '../../../domain/entities/category.dart';
import '../../../domain/entities/channel.dart';

/// Estados del catálogo de canales en directo.
sealed class LiveState extends Equatable {
  const LiveState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Cargando categorías y canales.
final class LiveLoading extends LiveState {
  const LiveLoading();
}

/// Catálogo cargado. [channels] son los canales de la categoría seleccionada.
final class LiveLoaded extends LiveState {
  const LiveLoaded({
    required this.categories,
    required this.selectedCategoryId,
    required this.channels,
  });

  final List<Category> categories;
  final int? selectedCategoryId;
  final List<Channel> channels;

  bool get isAllSelected => selectedCategoryId == null;

  @override
  List<Object?> get props => <Object?>[
    categories,
    selectedCategoryId,
    channels,
  ];
}

/// Error al cargar el catálogo.
final class LiveFailure extends LiveState {
  const LiveFailure(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
