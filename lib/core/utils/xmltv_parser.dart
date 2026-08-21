import 'dart:isolate';

import '../../../domain/entities/epg.dart';

/// Función de parseo XMLTV ejecutada en un isolate.
///
/// [xmlContent] es el texto del fichero `.xml` (XMLTV) y se devuelven las
/// entradas de EPG normalizadas a [EpgEntry].
List<EpgEntry> parseXmltvSync(String xmlContent) {
  final List<EpgEntry> result = <EpgEntry>[];
  if (xmlContent.isEmpty) return result;

  final List<String> lines = xmlContent.split('\n');
  for (int i = 0; i < lines.length; i++) {
    final String line = lines[i].trim();
    if (!line.startsWith('<programme')) continue;

    final Programme? p = _parseProgrammeTag(line, lines, i);
    if (p != null) result.add(p.toEpgEntry());
  }
  return result;
}

/// Parseo de un tag `<programme ...>title</programme>`.
Programme? _parseProgrammeTag(String tagLine, List<String> lines, int index) {
  // <programme start="20240101000000 +0100" stop="20240101010000 +0100" channel="id">
  final String? startRaw = _attr(tagLine, 'start');
  final String? stopRaw = _attr(tagLine, 'stop');
  final String? channel = _attr(tagLine, 'channel');
  if (startRaw == null || stopRaw == null) return null;

  // Busca el contenido <title>...</title> en las líneas siguientes.
  String title = '';
  String description = '';
  for (int j = index; j < lines.length; j++) {
    final String l = lines[j].trim();
    final String? t = _tagContent(l, 'title');
    if (t != null && title.isEmpty) title = t;
    final String? d = _tagContent(l, 'desc');
    if (d != null && description.isEmpty) description = d;
    if (l.startsWith('</programme>')) break;
  }

  return Programme(
    channel: channel ?? '',
    title: title,
    description: description,
    start: _parseXmltvTime(startRaw),
    stop: _parseXmltvTime(stopRaw),
  );
}

/// Extrae el valor de un atributo de un tag XML.
String? _attr(String tag, String name) {
  final RegExp re = RegExp('$name="([^"]*)"');
  final Match? m = re.firstMatch(tag);
  return m?.group(1);
}

/// Extrae el contenido de un par `<tag>...</tag>` en una misma línea,
/// soportando atributos en la etiqueta (p.ej. `<title lang="es">`).
String? _tagContent(String line, String tag) {
  final RegExp re = RegExp('<$tag[^>]*>([^<]*)</$tag>');
  final Match? m = re.firstMatch(line);
  return m?.group(1);
}

/// Convierte el formato de hora XMLTV (yyyymmddHHMMSS [+-]HHMM) a [DateTime] UTC.
DateTime? _parseXmltvTime(String raw) {
  final RegExp re = RegExp(
    r'^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})',
  );
  final Match? m = re.firstMatch(raw.trim());
  if (m == null) return null;
  final int y = int.parse(m.group(1)!);
  final int mo = int.parse(m.group(2)!);
  final int d = int.parse(m.group(3)!);
  final int h = int.parse(m.group(4)!);
  final int mi = int.parse(m.group(5)!);
  final int s = int.parse(m.group(6)!);
  return DateTime.utc(y, mo, d, h, mi, s);
}

/// Representación intermedia de un programa XMLTV.
class Programme {
  const Programme({
    required this.channel,
    required this.title,
    required this.description,
    this.start,
    this.stop,
  });

  final String channel;
  final String title;
  final String description;
  final DateTime? start;
  final DateTime? stop;

  EpgEntry toEpgEntry() {
    final DateTime s = start ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    final DateTime e = stop ?? s.add(const Duration(hours: 1));
    return EpgEntry(title: title, start: s, end: e, description: description);
  }
}

/// Ejecuta [parseXmltvSync] en un isolate para no bloquear la UI.
Future<List<EpgEntry>> parseXmltvInIsolate(String xmlContent) async {
  return Isolate.run<List<EpgEntry>>(() => parseXmltvSync(xmlContent));
}

/// Agrupa el EPG XMLTV por identificador de canal (`channel` del `<programme>`).
///
/// Devuelve un mapa `tvg-id → lista de programas`, útil para cruzar con los
/// canales de una lista M3U. Se ejecuta en un isolate.
Future<Map<String, List<EpgEntry>>> parseXmltvGroupedInIsolate(
  String xmlContent,
) async {
  return Isolate.run<Map<String, List<EpgEntry>>>(() {
    return parseXmltvGroupedSync(xmlContent);
  });
}

/// Variante síncrona de [parseXmltvGroupedInIsolate] (uso interno/tests).
Map<String, List<EpgEntry>> parseXmltvGroupedSync(String xmlContent) {
  final Map<String, List<EpgEntry>> grouped = <String, List<EpgEntry>>{};
  final List<String> lines = xmlContent.split('\n');
  for (int i = 0; i < lines.length; i++) {
    final String line = lines[i].trim();
    if (!line.startsWith('<programme')) continue;
    final Programme? p = _parseProgrammeTag(line, lines, i);
    if (p == null || p.channel.isEmpty) continue;
    grouped.putIfAbsent(p.channel, () => <EpgEntry>[]).add(p.toEpgEntry());
  }
  for (final List<EpgEntry> list in grouped.values) {
    list.sort((EpgEntry a, EpgEntry b) => a.start.compareTo(b.start));
  }
  return grouped;
}
