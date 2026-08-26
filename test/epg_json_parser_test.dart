import 'package:flutter_test/flutter_test.dart';

import 'package:kylora/core/utils/epg_json_parser.dart';
import 'package:kylora/domain/entities/epg.dart';

void main() {
  test('parsea EPG JSON estilo LaQuay (lista de {name, events})', () {
    const String json =
        '''[{"name":"CH1","events":[{"hi":1750000000,"hf":1750003600,"t":"Noticias","d":"Resumen"},{"hi":1750003600,"hf":1750007200,"t":"Cine","d":"Comedia"}]},{"name":"CH2","events":[]}]''';
    final Map<String, List<EpgEntry>> grouped = parseEpgJsonGroupedSync(json);
    expect(grouped.length, 1);
    expect(grouped['CH1'], isNotNull);
    final List<EpgEntry> entries = grouped['CH1']!;
    expect(entries.length, 2);
    expect(entries.first.title, 'Noticias');
    expect(entries.first.start, DateTime.fromMillisecondsSinceEpoch(
      1750000000 * 1000,
      isUtc: true,
    ));
  });

  test('parsea EPG JSON estilo mapa canal → lista', () {
    const String json =
        '''{"CH9":[{"start":1750000000,"end":1750003600,"title":"A","desc":"dA"},{"hi":1750003600,"hf":1750007200,"t":"B"}]}''';
    final Map<String, List<EpgEntry>> grouped = parseEpgJsonGroupedSync(json);
    expect(grouped['CH9']?.length, 2);
    expect(grouped['CH9']?.first.title, 'A');
  });

  test('detecta JSON por contenido en parseEpgGroupedInIsolate', () async {
    final Map<String, List<EpgEntry>> x = await parseEpgGroupedInIsolate(
      '[{"name":"K","events":[{"hi":1750000000,"hf":1750003600,"t":"P"}]}]',
    );
    expect(x['K']?.length, 1);
  });

  test('JSON mal formado devuelve vacío sin lanzar', () {
    expect(parseEpgJsonGroupedSync('no es json'), isEmpty);
    expect(parseEpgJsonGroupedSync(''), isEmpty);
    expect(parseEpgJsonGroupedSync('{"x": 42}'), isEmpty);
  });
}