import '../../domain/entities/category.dart';

/// DTO de una categoría devuelta por `get_live_categories.php`.
class XtreamCategoryDto {
  const XtreamCategoryDto({required this.id, required this.name});

  final int id;
  final String name;

  factory XtreamCategoryDto.fromJson(Map<String, dynamic> json) {
    return XtreamCategoryDto(
      id: int.tryParse(json['category_id']?.toString() ?? '') ?? 0,
      name: json['category_name'] as String? ?? '',
    );
  }

  Category toEntity() => Category(id: id, name: name);
}
