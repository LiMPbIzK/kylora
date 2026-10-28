import 'package:flutter_test/flutter_test.dart';

import 'package:kylora/core/utils/video_resolution.dart';

void main() {
  test('videoResolutionLabel etiqueta las resoluciones habituales', () {
    expect(videoResolutionLabel(480), '480p');
    expect(videoResolutionLabel(540), '540p');
    expect(videoResolutionLabel(576), '576p');
    expect(videoResolutionLabel(720), '720p');
    expect(videoResolutionLabel(1080), '1080p');
    expect(videoResolutionLabel(1088), '1080p');
    expect(videoResolutionLabel(1440), '1440p');
    expect(videoResolutionLabel(2160), '2160p');
    expect(videoResolutionLabel(4320), '4320p');
  });

  test('videoResolutionLabel devuelve null si no hay altura válida', () {
    expect(videoResolutionLabel(null), isNull);
    expect(videoResolutionLabel(0), isNull);
    expect(videoResolutionLabel(-1), isNull);
  });
}
