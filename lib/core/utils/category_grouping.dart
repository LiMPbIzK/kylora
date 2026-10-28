import '../../domain/entities/category.dart';

/// Agrupación de categorías de canales por región/país.
///
/// Los proveedores IPTV suelen nombrar las categorías con prefijos del tipo
/// `EU- ES ...`, `LA- MEXICO`, `VIP US- ...`, `EST EU- BULGARIA`... A veces el
/// orden que llega (o el que quedó en la caché) mezcla países. Este helper
/// detecta el país de cada categoría y las agrupa sin tocar la lista si ya
/// viene agrupada.

const List<MapEntry<String, String>> _specialCountries =
    <MapEntry<String, String>>[
      MapEntry<String, String>('UNITED KINGDOM', 'GB'),
      MapEntry<String, String>('UNITED STATES', 'US'),
      MapEntry<String, String>('COSTA RICA', 'CR'),
      MapEntry<String, String>('PUERTO RICO', 'PR'),
      MapEntry<String, String>('SOUTH AFRICA', 'ZA'),
      MapEntry<String, String>('NEW ZEALAND', 'NZ'),
      MapEntry<String, String>('SRI LANKA', 'LK'),
      MapEntry<String, String>('EL SALVADOR', 'SV'),
      MapEntry<String, String>('SWITZERLAND', 'CH'),
      MapEntry<String, String>('LUXEMBOURG', 'LU'),
      MapEntry<String, String>('DOMINICAN', 'DO'),
      MapEntry<String, String>('CARIBBEAN', 'CARIBBEAN'),
      MapEntry<String, String>('BALTIC', 'BALTIC'),
      MapEntry<String, String>('LATIN', 'LATAM'),
      MapEntry<String, String>('LATINO', 'LATAM'),
      MapEntry<String, String>('MEXICO', 'MX'),
      MapEntry<String, String>('BRASIL', 'BR'),
      MapEntry<String, String>('BRAZIL', 'BR'),
      MapEntry<String, String>('ARGENTINA', 'AR'),
      MapEntry<String, String>('COLOMBIA', 'CO'),
      MapEntry<String, String>('VENEZUELA', 'VE'),
      MapEntry<String, String>('ECUADOR', 'EC'),
      MapEntry<String, String>('BOLIVIA', 'BO'),
      MapEntry<String, String>('PARAGUAY', 'PY'),
      MapEntry<String, String>('URUGUAY', 'UY'),
      MapEntry<String, String>('CHILE', 'CL'),
      MapEntry<String, String>('PERU', 'PE'),
      MapEntry<String, String>('PANAMA', 'PA'),
      MapEntry<String, String>('CUBA', 'CU'),
      MapEntry<String, String>('HAITI', 'HT'),
      MapEntry<String, String>('HONDURAS', 'HN'),
      MapEntry<String, String>('GUATEMALA', 'GT'),
      MapEntry<String, String>('NICARAGUA', 'NI'),
      MapEntry<String, String>('SURINAME', 'SR'),
      MapEntry<String, String>('TRINIDAD', 'TT'),
      MapEntry<String, String>('JAMAICA', 'JM'),
      MapEntry<String, String>('BULGARIA', 'BG'),
      MapEntry<String, String>('RUSSIA', 'RU'),
      MapEntry<String, String>('SERBIA', 'RS'),
      MapEntry<String, String>('CROATIA', 'HR'),
      MapEntry<String, String>('BOSNIA', 'BA'),
      MapEntry<String, String>('MACEDONIA', 'MK'),
      MapEntry<String, String>('SLOVENIA', 'SI'),
      MapEntry<String, String>('SLOVAKIA', 'SK'),
      MapEntry<String, String>('CZECH', 'CZ'),
      MapEntry<String, String>('HUNGARY', 'HU'),
      MapEntry<String, String>('ROMANIA', 'RO'),
      MapEntry<String, String>('ALBANIA', 'AL'),
      MapEntry<String, String>('GREECE', 'GR'),
      MapEntry<String, String>('GREEK', 'GR'),
      MapEntry<String, String>('CYPRUS', 'CY'),
      MapEntry<String, String>('UKRAINE', 'UA'),
      MapEntry<String, String>('ARMENIA', 'AM'),
      MapEntry<String, String>('AZERBAIJAN', 'AZ'),
      MapEntry<String, String>('MOLDOVA', 'MD'),
      MapEntry<String, String>('ESTONIA', 'EE'),
      MapEntry<String, String>('LATVIA', 'LV'),
      MapEntry<String, String>('LITHUANIA', 'LT'),
      MapEntry<String, String>('AUSTRALIA', 'AU'),
      MapEntry<String, String>('CANADA', 'CA'),
      MapEntry<String, String>('IRELAND', 'IE'),
      MapEntry<String, String>('AUSTRIA', 'AT'),
      MapEntry<String, String>('POLAND', 'PL'),
      MapEntry<String, String>('MALTA', 'MT'),
      MapEntry<String, String>('PORTUGAL', 'PT'),
      MapEntry<String, String>('SPAIN', 'ES'),
      MapEntry<String, String>('FRANCE', 'FR'),
      MapEntry<String, String>('GERMANY', 'DE'),
      MapEntry<String, String>('ITALY', 'IT'),
      MapEntry<String, String>('NETHERLANDS', 'NL'),
      MapEntry<String, String>('BELGIUM', 'BE'),
      MapEntry<String, String>('ISRAEL', 'IL'),
      MapEntry<String, String>('TURKEY', 'TR'),
      MapEntry<String, String>('TURKIYE', 'TR'),
      MapEntry<String, String>('LEBANON', 'LB'),
      MapEntry<String, String>('JORDAN', 'JO'),
      MapEntry<String, String>('SAUDI', 'SA'),
      MapEntry<String, String>('QATAR', 'QA'),
      MapEntry<String, String>('KUWAIT', 'KW'),
      MapEntry<String, String>('BAHRAIN', 'BH'),
      MapEntry<String, String>('MOROCCO', 'MA'),
      MapEntry<String, String>('ALGERIA', 'DZ'),
      MapEntry<String, String>('TUNISIA', 'TN'),
      MapEntry<String, String>('EGYPT', 'EG'),
      MapEntry<String, String>('NIGERIA', 'NG'),
      MapEntry<String, String>('KENYA', 'KE'),
      MapEntry<String, String>('PAKISTAN', 'PK'),
      MapEntry<String, String>('BANGLADESH', 'BD'),
      MapEntry<String, String>('NEPAL', 'NP'),
      MapEntry<String, String>('CHINA', 'CN'),
      MapEntry<String, String>('JAPAN', 'JP'),
      MapEntry<String, String>('KOREA', 'KR'),
      MapEntry<String, String>('THAILAND', 'TH'),
      MapEntry<String, String>('VIETNAM', 'VN'),
      MapEntry<String, String>('PHILIPPINES', 'PH'),
      MapEntry<String, String>('INDONESIA', 'ID'),
      MapEntry<String, String>('MALAYSIA', 'MY'),
      MapEntry<String, String>('SINGAPORE', 'SG'),
      MapEntry<String, String>('HONG KONG', 'HK'),
      MapEntry<String, String>('TAIWAN', 'TW'),
    ];

const Map<String, String> _tokenAliases = <String, String>{
  'UK': 'GB',
  'GBR': 'GB',
  'AUS': 'AU',
  'IRE': 'IE',
  'IRL': 'IE',
  'ALB': 'AL',
  'BIH': 'BA',
  'MKD': 'MK',
  'USA': 'US',
  'LAT': 'LATAM',
  'CAR': 'CARIBBEAN',
  'PPV': 'EVENTS',
  'BALTIC': 'BALTIC',
};

/// Tokens que no deben interpretarse como país (regiones, formatos, etc.).
const Set<String> _stopTokens = <String>{
  'EU',
  'LA',
  'EX',
  'YU',
  'EST',
  'VIP',
  'TV',
  'HD',
  'SD',
  'FHD',
  'UHD',
  '4K',
  'VOD',
  'OK',
  'PC',
  'APP',
  'MAX',
  'NBA',
  'NFL',
  'MLB',
  'NHL',
  'UFC',
};

String _normalize(String value) {
  return value
      .toUpperCase()
      .replaceAll('Á', 'A')
      .replaceAll('À', 'A')
      .replaceAll('Ä', 'A')
      .replaceAll('Â', 'A')
      .replaceAll('É', 'E')
      .replaceAll('È', 'E')
      .replaceAll('Ë', 'E')
      .replaceAll('Ê', 'E')
      .replaceAll('Í', 'I')
      .replaceAll('Ì', 'I')
      .replaceAll('Ï', 'I')
      .replaceAll('Î', 'I')
      .replaceAll('Ó', 'O')
      .replaceAll('Ò', 'O')
      .replaceAll('Ö', 'O')
      .replaceAll('Ô', 'O')
      .replaceAll('Ú', 'U')
      .replaceAll('Ù', 'U')
      .replaceAll('Ü', 'U')
      .replaceAll('Û', 'U')
      .replaceAll('Ñ', 'N')
      .replaceAll('Ç', 'C')
      .replaceAll(RegExp(r'[^A-Z0-9+ ]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

bool _matchesWord(String text, String word) {
  return RegExp('(^| )${RegExp.escape(word)}( |\$)').hasMatch(text);
}

String _specialCountry(String normalized) {
  for (final MapEntry<String, String> entry in _specialCountries) {
    if (_matchesWord(normalized, entry.key)) return entry.value;
  }
  return '';
}

int _regionTokenStart(String region) {
  return switch (region) {
    'EU' => 1,
    'LA' => 1,
    '24/7' => 2,
    'EST EU' => 2,
    'EXYU' => 2,
    _ when region.startsWith('VIP ') => 2,
    _ => 1,
  };
}

/// Región/agrupación temática de una categoría (EU, LA, VIP US, EST EU...).
String categoryRegionKey(String name) {
  final String n = _normalize(name);
  if (n.startsWith('VIP ')) {
    final List<String> tokens = n.split(' ');
    return tokens.length > 1 ? 'VIP ${tokens[1]}' : 'VIP';
  }
  if (n.startsWith('EST EU')) return 'EST EU';
  if (n.startsWith('EX YU') || n.startsWith('EXYU')) return 'EXYU';
  if (n.startsWith('24 7')) return '24/7';
  if (n.startsWith('EU ')) return 'EU';
  if (n.startsWith('LA ')) return 'LA';
  if (n.startsWith('IS ')) return 'IS';
  return n.split(' ').first;
}

/// País detectado para una categoría (código ISO o nombre normalizado).
///
/// Es heurístico: usa nombres conocidos y, si no, el primer token del país
/// después del prefijo de región. Devuelve `ZZ` si no puede determinarlo.
String categoryCountryKey(String name) {
  final String n = _normalize(name);
  final String region = categoryRegionKey(name);

  // Las categorías `IS- ...` del proveedor son Israel (contenido en hebreo),
  // no Islandia (código ISO IS).
  if (region == 'IS') return 'IL';

  final String special = _specialCountry(n);
  if (special.isNotEmpty) return special;

  final List<String> tokens = n.split(' ');
  for (final String token in tokens) {
    final String? alias = _tokenAliases[token];
    if (alias != null) return alias;
    if (RegExp(r'^[A-Z]{2}$').hasMatch(token) && !_stopTokens.contains(token)) {
      return token;
    }
  }

  final int start = _regionTokenStart(region);
  if (start < tokens.length) {
    for (int i = start; i < tokens.length; i++) {
      final String token = tokens[i];
      if (token.length < 2 || _stopTokens.contains(token)) continue;
      if (!RegExp(r'^[A-Z]').hasMatch(token)) continue;
      return token;
    }
  }

  return region == 'EXYU' ? 'EXYU' : 'ZZ';
}

/// Grupo completo región+país.
String categoryGroupKey(String name) =>
    '${categoryRegionKey(name)}|${categoryCountryKey(name)}';

/// Agrupa las categorías de canales por región y país.
///
/// - Si ya están agrupadas (cada grupo aparece en un único bloque contiguo),
///   devuelve la misma lista sin tocar el orden del proveedor.
/// - Si están mezcladas, respeta el orden de aparición de las regiones y de los
///   países, pero adelanta España dentro de su región para que el contenido en
///   español quede junto y accesible.
List<Category> groupCategoriesByRegionAndCountry(List<Category> categories) {
  if (categories.length < 2) return categories;

  final List<String> groupKeys = categories
      .map((Category category) => categoryGroupKey(category.name))
      .toList();

  // ¿Ya está agrupada? Cada región debe aparecer en un único bloque y, dentro
  // de ella, cada país en un único bloque contiguo.
  final Set<String> seenRegions = <String>{};
  final Set<String> seenGroups = <String>{};
  String? previousRegion;
  String? previousGroup;
  for (final String key in groupKeys) {
    final String region = key.substring(0, key.indexOf('|'));
    if (region != previousRegion) {
      if (seenRegions.contains(region)) {
        return _regroup(categories, groupKeys);
      }
      seenRegions.add(region);
      previousRegion = region;
    }
    if (key != previousGroup) {
      if (seenGroups.contains(key)) {
        return _regroup(categories, groupKeys);
      }
      seenGroups.add(key);
      previousGroup = key;
    }
  }
  return categories;
}

List<Category> _regroup(List<Category> categories, List<String> groupKeys) {
  final Map<String, List<Category>> groups = <String, List<Category>>{};
  for (int i = 0; i < categories.length; i++) {
    groups.putIfAbsent(groupKeys[i], () => <Category>[]).add(categories[i]);
  }

  // Orden de regiones: primera aparición.
  final List<String> regionOrder = <String>[];
  final Map<String, List<String>> countriesByRegion = <String, List<String>>{};
  for (final String key in groups.keys) {
    final int separator = key.indexOf('|');
    final String region = key.substring(0, separator);
    final String country = key.substring(separator + 1);
    if (!regionOrder.contains(region)) {
      regionOrder.add(region);
      countriesByRegion[region] = <String>[];
    }
    countriesByRegion[region]!.add(country);
  }

  final List<String> orderedKeys = <String>[];
  for (final String region in regionOrder) {
    final List<String> countries = countriesByRegion[region]!;
    // `List.sort` no es estable: se ordena con el índice original para no
    // alterar el orden de los países que no son España.
    final List<MapEntry<int, String>> indexed =
        countries.asMap().entries.toList()
          ..sort((MapEntry<int, String> a, MapEntry<int, String> b) {
            if (a.value == b.value) return a.key.compareTo(b.key);
            if (a.value == 'ES') return -1;
            if (b.value == 'ES') return 1;
            return a.key.compareTo(b.key);
          });
    for (final MapEntry<int, String> entry in indexed) {
      orderedKeys.add('$region|${entry.value}');
    }
  }

  return <Category>[for (final String key in orderedKeys) ...groups[key]!];
}
