import 'package:equatable/equatable.dart';

/// Visibilidad y orden de una categoría para una cuenta.
class CategoryPreference extends Equatable {
  const CategoryPreference({
    required this.categoryId,
    this.hidden = false,
    this.sortOrder = 0,
  });

  final int categoryId;
  final bool hidden;
  final int sortOrder;

  @override
  List<Object?> get props => <Object?>[categoryId, hidden, sortOrder];
}
