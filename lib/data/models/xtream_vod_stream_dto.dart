import '../../domain/entities/movie.dart';

/// DTO de una película devuelta por `get_vod_streams.php`.
class XtreamVodStreamDto {
  const XtreamVodStreamDto({
    required this.streamId,
    required this.name,
    required this.categoryId,
    this.number,
    this.streamType,
    this.streamIcon,
    this.rating,
    this.rating5Based,
    this.added,
    this.containerExtension,
    this.customSkin,
    this.directSource,
  });

  final int streamId;
  final String name;
  final int categoryId;
  final int? number;
  final String? streamType;
  final String? streamIcon;
  final String? rating;
  final String? rating5Based;
  final String? added;
  final String? containerExtension;
  final String? customSkin;
  final String? directSource;

  factory XtreamVodStreamDto.fromJson(Map<String, dynamic> json) {
    return XtreamVodStreamDto(
      streamId: int.tryParse(json['stream_id']?.toString() ?? '') ?? 0,
      name: json['name'] as String? ?? '',
      categoryId: int.tryParse(json['category_id']?.toString() ?? '') ?? 0,
      number: int.tryParse(json['num']?.toString() ?? ''),
      streamType: _str(json['stream_type']),
      streamIcon: _str(json['stream_icon']),
      rating: _str(json['rating']),
      rating5Based: _str(json['rating_5based']),
      added: _str(json['added']),
      containerExtension: _str(json['container_extension']),
      customSkin: _str(json['custom_sid']),
      directSource: _str(json['direct_source']),
    );
  }

  /// Convierte cualquier valor JSON (string o número) a `String?`.
  static String? _str(dynamic value) => value?.toString();

  Movie toEntity() => Movie(
    id: streamId,
    name: name,
    categoryId: categoryId,
    number: number,
    streamType: streamType,
    streamIcon: streamIcon,
    rating: rating,
    rating5Based: rating5Based,
    added: added,
    containerExtension: containerExtension,
    customSkin: customSkin,
    directSource: directSource,
  );
}
