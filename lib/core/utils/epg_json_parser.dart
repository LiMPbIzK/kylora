import 'dart:convert';
import 'dart:isolate';

import '../../../domain/entities/epg.dart';
import 'xmltv_parser.dart';

/// Parseo de una guía EPG detectando el formato por su **contenido** (no por
/// la URL): si empieza por `{`/`[` se interpreta como JSON (ver
/// [parseEpgJsonGroupedInIsolate]); en caso contrario como XMLTV estándar.
Future<Map<String, List<EpgEntry>>> parseEpgGroupedInIsolate(
  String content,
) async {
  final String trimmed = content.trimLeft();
  if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
    return parseEpgJsonGroupedInIsolate(content);
  }
  return parseXmltvGroupedInIsolate(content);
}

/// Parseo de guías EPG en formato JSON.
///
/// No existe un estándar unificado "EPG JSON"; cada proveedor usa su propio
/// esquema. Se soportan los dos esquemas más habituales en listas M3U:
///
/// 1. Estilo LaQuay/tdtechannels:
///    `[{"name":"La1.TV","events":[{"hi":1787,"hf":1788,"t":"Tit","d":"Desc"}]}]`
/// 2. Esquema mapa canal → lista (acepta `start`/`end` como epoch seg/ms o
///    ISO-8601, con claves `title`/`desc` o `t`/`d`).
///
/// Se ejecuta en un isolate.
Future<Map<String, List<EpgEntry>>> parseEpgJsonGroupedInIsolate(
  String jsonContent,
) async {
  return Isolate.run<Map<String, List<EpgEntry>>>(() {
    return parseEpgJsonGroupedSync(jsonContent);
  });
}

/// Variante síncrona (uso interno/tests).
Map<String, List<EpgEntry>> parseEpgJsonGroupedSync(String jsonContent) {
  final Map<String, List<EpgEntry>> grouped = <String, List<EpgEntry>>{};
  final dynamic root;
  try {
    root = jsonDecode(jsonContent);
  } on FormatException {
    return grouped;
  }
  if (root is! List && root is! Map) return grouped;

  // Esquema estilo LaQuay: lista de {name, events:[{hi,hf,t,d}]}.
  if (root is List) {
    for (final dynamic item in root) {
      if (item is! Map) continue;
      final String channel = _asString(item['name']);
      if (channel.isEmpty) continue;
      final dynamic events = item['events'];
      if (events is! List) continue;
      final List<EpgEntry> entries = <EpgEntry>[];
      for (final dynamic ev in events) {
        if (ev is! Map) continue;
        final DateTime? start = _epochSeconds(ev['hi']);
        final DateTime? end = _epochSeconds(ev['hf']);
        if (start == null || end == null) continue;
        entries.add(
          EpgEntry(
            title: _asString(ev['t']),
            start: start,
            end: end,
            description: _asString(ev['d']),
          ),
        );
      }
      if (entries.isNotEmpty) grouped[channel] = entries;
    }
    return grouped;
  }

  // Esquema mapa canal → lista de programas.
  root.forEach((dynamic key, dynamic value) {
    final String channel = key.toString();
    if (value is! List) return;
    final List<EpgEntry> entries = <EpgEntry>[];
    for (final dynamic ev in value) {
      if (ev is! Map) continue;
      final DateTime? start = _parseAnyTime(ev['start'], ev['hi']);
      final DateTime? end = _parseAnyTime(ev['end'], ev['hf']);
      if (start == null || end == null) continue;
      entries.add(
        EpgEntry(
          title: _asString(ev['title'] ?? ev['t']),
          start: start,
          end: end,
          description: _asString(ev['desc'] ?? ev['d']),
        ),
      );
    }
    if (entries.isNotEmpty) grouped[channel] = entries;
  });
  return grouped;
}

DateTime? _epochSeconds(dynamic value) {
  final String? raw = _asStringOrNull(value);
  if (raw == null || raw.isEmpty) return null;
  final int? epoch = int.tryParse(raw);
  if (epoch == null) return null;
  return DateTime.fromMillisecondsSinceEpoch(epoch * 1000, isUtc: true);
}

DateTime? _parseAnyTime(dynamic primary, dynamic secondary) {
  final DateTime? a = _epochSeconds(primary) ?? _parseIso(_asStringOrNull(primary));
  if (a != null) return a;
  return _epochSeconds(secondary) ?? _parseIso(_asStringOrNull(secondary));
}

DateTime? _parseIso(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw)?.toUtc();
}

String _asString(dynamic value) => _asStringOrNull(value) ?? '';

String? _asStringOrNull(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  return value.toString();
}