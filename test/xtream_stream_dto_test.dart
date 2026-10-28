import 'package:flutter_test/flutter_test.dart';

import 'package:kylora/data/models/xtream_stream_dto.dart';

void main() {
  test('XtreamStreamDto interpreta tv_archive y su duración', () {
    final XtreamStreamDto dto = XtreamStreamDto.fromJson(<String, dynamic>{
      'stream_id': '65974',
      'name': 'ES- La 1 HD',
      'category_id': '10',
      'tv_archive': 1,
      'tv_archive_duration': '7',
    });
    final channel = dto.toEntity();

    expect(channel.hasArchive, isTrue);
    expect(channel.archiveDurationDays, 7);
  });

  test('XtreamStreamDto acepta tv_archive como texto y ausente', () {
    final XtreamStreamDto withText = XtreamStreamDto.fromJson(<String, dynamic>{
      'stream_id': 1,
      'name': 'Canal',
      'category_id': 1,
      'tv_archive': '1',
      'tv_archive_duration': 1,
    });
    final XtreamStreamDto withoutArchive = XtreamStreamDto.fromJson(
      <String, dynamic>{'stream_id': 2, 'name': 'Canal 2', 'category_id': 1},
    );

    expect(withText.toEntity().hasArchive, isTrue);
    expect(withoutArchive.toEntity().hasArchive, isFalse);
    expect(withoutArchive.toEntity().archiveDurationDays, isNull);
  });
}
