import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:kylora/data/models/xtream_epg_dto.dart';
import 'package:kylora/domain/entities/epg.dart';

void main() {
  test('parsea listing normal sin alterar título y descripción', () {
    final EpgEntry? entry = XtreamEpgDto.parseListing(<String, dynamic>{
      'title': 'Noticias de la tarde',
      'start': 1700000000,
      'end': 1700003600,
      'description': 'Informativo con los titulares del día.',
    });

    expect(entry, isNotNull);
    expect(entry!.title, 'Noticias de la tarde');
    expect(entry.description, 'Informativo con los titulares del día.');
    expect(entry.start, DateTime.fromMillisecondsSinceEpoch(1700000000000));
  });

  test('descodifica título y descripción codificados en base64', () {
    final String title = base64.encode(utf8.encode('Deportes en vivo'));
    final String desc = base64.encode(
      utf8.encode('Resumen de la jornada con los mejores goles.'),
    );

    final EpgEntry? entry = XtreamEpgDto.parseListing(<String, dynamic>{
      'title': title,
      'start': 1700000000,
      'end': 1700003600,
      'description': desc,
    });

    expect(entry, isNotNull);
    expect(entry!.title, 'Deportes en vivo');
    expect(entry.description, 'Resumen de la jornada con los mejores goles.');
  });

  test('conserva texto que no es base64 válido', () {
    final EpgEntry? entry = XtreamEpgDto.parseListing(<String, dynamic>{
      'title': 'News',
      'start': 1700000000,
      'end': 1700003600,
      'description': '19901121',
    });

    expect(entry, isNotNull);
    expect(entry!.title, 'News');
    expect(entry.description, '19901121');
  });
}