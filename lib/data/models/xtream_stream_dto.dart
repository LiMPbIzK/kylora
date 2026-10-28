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
    this.hasArchive = false,
    this.archiveDurationDays,
  });

  final int streamId;
  final String name;
  final int categoryId;
  final int? number;
  final String? logo;
  final String? epgChannelId;
  final bool hasArchive;
  final int? archiveDurationDays;

  factory XtreamStreamDto.fromJson(Map<String, dynamic> json) {
    return XtreamStreamDto(
      streamId: int.tryParse(json['stream_id']?.toString() ?? '') ?? 0,
      name: json['name'] as String? ?? '',
      categoryId: int.tryParse(json['category_id']?.toString() ?? '') ?? 0,
      number: int.tryParse(json['num']?.toString() ?? ''),
      logo: json['stream_icon'] as String?,
      epgChannelId: json['epg_channel_id'] as String?,
      hasArchive: _asBool(json['tv_archive']),
      archiveDurationDays: int.tryParse(
        json['tv_archive_duration']?.toString() ?? '',
      ),
    );
  }

  Channel toEntity() => Channel(
    id: streamId,
    name: name,
    categoryId: categoryId,
    number: number,
    logo: logo,
    epgChannelId: epgChannelId,
    hasArchive: hasArchive,
    archiveDurationDays: archiveDurationDays,
  );

  static bool _asBool(Object? value) {
    if (value == true || value == 1) return true;
    final String text = value?.toString().toLowerCase() ?? '';
    return text == '1' || text == 'true' || text == 'yes';
  }
}
