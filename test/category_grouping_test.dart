import 'package:flutter_test/flutter_test.dart';

import 'package:kylora/core/utils/category_grouping.dart';
import 'package:kylora/domain/entities/category.dart';

Category _cat(int id, String name) => Category(id: id, name: name);

void main() {
  test('categoryCountryKey detecta países de los prefijos habituales', () {
    expect(categoryCountryKey('EU- ES TDT'), 'ES');
    expect(categoryCountryKey('EU- NL ALGEMEEN'), 'NL');
    expect(categoryCountryKey('EU- IT TVSAT'), 'IT');
    expect(categoryCountryKey('EU- DE SWITZERLAND'), 'CH');
    expect(categoryCountryKey('EU- UK SKY'), 'GB');
    expect(categoryCountryKey('EST EU- BULGARIA'), 'BG');
    expect(categoryCountryKey('EST EU-RO Documentare'), 'RO');
    expect(categoryCountryKey('VIP US- NBC NETWORK'), 'US');
    expect(categoryCountryKey('VIP AUS- STAN SPORT'), 'AU');
    expect(categoryCountryKey('VIP LAT- TUDN SPORTS'), 'LATAM');
    expect(categoryCountryKey('EX-YU- SERBIA'), 'RS');
    expect(categoryCountryKey('EXYU- CROATIA'), 'HR');
    expect(categoryCountryKey('LA- PRIME MEXICO EVENT'), 'MX');
    expect(categoryCountryKey('LA-  Puerto Rico'), 'PR');
    expect(categoryCountryKey('LA- CARIBBEAN (AMP)'), 'CARIBBEAN');
    expect(categoryCountryKey('24/7| FR PLUTO'), 'FR');
    expect(categoryCountryKey('IS- GENERAL | ??????'), 'IL');
  });

  test('no toca una lista que ya está agrupada por región/país', () {
    final List<Category> categories = <Category>[
      _cat(1, 'EU- ES TDT'),
      _cat(2, 'EU- PT GENERALISTAS'),
      _cat(3, 'EU- DE ALLGEMEIN'),
      _cat(4, 'LA- MEXICO'),
      _cat(5, 'LA- ARGENTINA'),
    ];
    expect(groupCategoriesByRegionAndCountry(categories), same(categories));
  });

  test('agrupa una lista mezclada y adelanta España dentro de su región', () {
    final List<Category> categories = <Category>[
      _cat(1, 'EU- NL ALGEMEEN'),
      _cat(2, 'EU- IT TVSAT'),
      _cat(3, 'EU- DE ALLGEMEIN'),
      _cat(4, 'EU- ES TDT'),
      _cat(5, 'EU- BE VLAAMS'),
      _cat(6, 'EST EU- BULGARIA'),
      _cat(7, 'EU- DE SWITZERLAND'),
      _cat(8, 'EST EU- RUSSIA'),
      _cat(9, 'LA- BRASIL'),
      _cat(10, 'LA- MEXICO'),
    ];

    final List<Category> grouped = groupCategoriesByRegionAndCountry(
      categories,
    );
    expect(grouped.map((Category category) => category.name).toList(), <String>[
      'EU- ES TDT',
      'EU- NL ALGEMEEN',
      'EU- IT TVSAT',
      'EU- DE ALLGEMEIN',
      'EU- BE VLAAMS',
      'EU- DE SWITZERLAND',
      'EST EU- BULGARIA',
      'EST EU- RUSSIA',
      'LA- BRASIL',
      'LA- MEXICO',
    ]);
  });
}
