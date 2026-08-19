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
    this.query = '',
  });

  final List<Category> categories;
  final int? selectedCategoryId;
  final List<Channel> channels;
  final String query;

  bool get isAllSelected => selectedCategoryId == null;
  bool get isSearching => query.trim().isNotEmpty;

  @override
  List<Object?> get props => <Object?>[
    categories,
    selectedCategoryId,
    channels,
    query,
  ];
}

/// Error al cargar el catálogo.
final class LiveFailure extends LiveState {
  const LiveFailure(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
