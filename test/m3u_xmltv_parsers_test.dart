import 'package:flutter_test/flutter_test.dart';

import 'package:kylora/core/utils/m3u_parser.dart';
import 'package:kylora/core/utils/xmltv_parser.dart';
import 'package:kylora/domain/entities/epg.dart';

void main() {
  group('M3U parser', () {
    test('parsea canales con atributos extendidos', () {
      const String content = '''
#EXTM3U
#EXTINF:-1 tvg-id="esp.sports" tvg-name="Sports HD" tvg-logo="http://x/logo.png" group-title="Deportes",Sports HD
http://server/live/sports.m3u8
#EXTINF:-1 tvg-id="esp.news" group-title="Noticias",News 24
http://server/live/news.m3u8
''';
      final List<M3uEntry> entries = parseM3u(content);
      expect(entries, hasLength(2));

      final M3uEntry first = entries[0];
      expect(first.name, 'Sports HD');
      expect(first.url, 'http://server/live/sports.m3u8');
      expect(first.tvgId, 'esp.sports');
      expect(first.tvgName, 'Sports HD');
      expect(first.logo, 'http://x/logo.png');
      expect(first.groupTitle, 'Deportes');
      expect(first.duration, -1);

      final M3uEntry second = entries[1];
      expect(second.groupTitle, 'Noticias');
      expect(second.name, 'News 24');
      expect(second.tvgId, 'esp.news');
    });

    test('maneja nombres con comas', () {
      const String content = '''
#EXTM3U
#EXTINF:-1 tvg-name="News, Prime" group-title="News & Talk",News, Prime
http://server/live/news.m3u8
''';
      final List<M3uEntry> entries = parseM3u(content);
      expect(entries, hasLength(1));
      expect(entries.first.name, 'News, Prime');
      expect(entries.first.groupTitle, 'News & Talk');
    });

    test('devuelve lista vacía para contenido sin canales', () {
      final List<M3uEntry> entries = parseM3u('comentario\n');
      expect(entries, isEmpty);
    });
  });

  group('XMLTV parser', () {
    test('parsea programas y los agrupa por canal', () {
      const String content = '''
<?xml version="1.0" encoding="UTF-8"?>
<tv>
<channel id="esp.sports"><display-name>Sports</display-name></channel>
<programme start="20240801000000 +0000" stop="20240801010000 +0000" channel="esp.sports">
<title lang="es">Fútbol en directo</title>
<desc lang="es">Partido de la jornada 1.</desc>
</programme>
<programme start="20240802000000 +0000" stop="20240802020000 +0000" channel="esp.sports">
<title lang="es">Resumen</title>
</programme>
</tv>
''';
      final Map<String, List<EpgEntry>> grouped =
          parseXmltvGroupedSync(content);
      expect(grouped, contains('esp.sports'));
      final List<EpgEntry> entries = grouped['esp.sports']!;
      expect(entries, hasLength(2));

      final EpgEntry first = entries[0];
      expect(first.title, 'Fútbol en directo');
      expect(first.description, 'Partido de la jornada 1.');
      expect(first.start, DateTime.utc(2024, 8, 1, 0, 0, 0));
      expect(first.end, DateTime.utc(2024, 8, 1, 1, 0, 0));

      final EpgEntry second = entries[1];
      expect(
        second.start,
        DateTime.utc(2024, 8, 2, 0, 0, 0),
      );
    });

    test('devuelve mapa vacío para XML sin programmes', () {
      const String content = '<tv><channel id="x"><display-name>x</display-name></channel></tv>';
      final Map<String, List<EpgEntry>> grouped =
          parseXmltvGroupedSync(content);
      expect(grouped, isEmpty);
    });
  });
}