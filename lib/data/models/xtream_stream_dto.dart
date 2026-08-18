import '../../domain/entities/channel.dart';

/// DTO de un canal devuelto por `get_live_streams.php`.
class XtreamStreamDto {
  const XtreamStreamDto({
    required this.streamId,
    required this.name,
    required this.categoryId,
    this.number,
    this.logo,
    this.epgChannelId,
  });

  final int streamId;
  final String name;
  final int categoryId;
  final int? number;
  final String? logo;
  final String? epgChannelId;

  factory XtreamStreamDto.fromJson(Map<String, dynamic> json) {
    return XtreamStreamDto(
      streamId: int.tryParse(json['stream_id']?.toString() ?? '') ?? 0,
      name: json['name'] as String? ?? '',
      categoryId: int.tryParse(json['category_id']?.toString() ?? '') ?? 0,
      number: int.tryParse(json['num']?.toString() ?? ''),
      logo: json['stream_icon'] as String?,
      epgChannelId: json['epg_channel_id'] as String?,
    );
  }

  Channel toEntity() => Channel(
    id: streamId,
    name: name,
    categoryId: categoryId,
    number: number,
    logo: logo,
    epgChannelId: epgChannelId,
  );
}
