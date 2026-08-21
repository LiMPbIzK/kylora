import 'dart:isolate';

/// Entrada individual de una lista M3U.
class M3uEntry {
  const M3uEntry({
    required this.url,
    required this.name,
    this.logo,
    this.groupTitle,
    this.tvgId,
    this.tvgName,
    this.duration = -1,
  });

  /// URL directa del stream.
  final String url;

  /// Nombre del canal o contenido.
  final String name;

  /// URL del logotipo (`tvg-logo`).
  final String? logo;

  /// Grupo/categoría (`group-title`).
  final String? groupTitle;

  /// Identificador para el EPG XMLTV (`tvg-id`).
  final String? tvgId;

  /// Nombre de canal según `tvg-name`.
  final String? tvgName;

  /// Duración en segundos (`-1` para live, duración real para VOD).
  final int duration;
}

/// Parseo completo de un fichero M3U.
///
/// Devuelve la lista de entradas ordenadas tal y como aparecen en el fichero.
List<M3uEntry> parseM3u(String content) {
  final List<M3uEntry> entries = <M3uEntry>[];
  final List<String> lines = content.split('\n');
  String? pendingExtInf;

  bool hasHeader = false;
  for (final String rawLine in lines) {
    final String line = rawLine.trim();
    if (line.isEmpty) continue;

    if (line.startsWith('#')) {
      if (line.startsWith('#EXTM3U')) hasHeader = true;
      if (line.startsWith('#EXTINF')) {
        pendingExtInf = line;
      }
      // #EXTGRP, #PLAYLIST, comentarios... se ignoran.
      continue;
    }

    // Línea de URL. Solo cuenta si hay encabezado #EXTM3U y (si el fichero
    // usa #EXTINF) viene precedida por una línea de metadatos.
    if (!hasHeader) continue;
    if (pendingExtInf == null && _hasExtInf(lines)) continue;

    final String url = line;
    String name = url;
    int duration = -1;
    String? logo;
    String? groupTitle;
    String? tvgId;
    String? tvgName;

    if (pendingExtInf != null) {
      final ExtInf parsed = _parseExtInf(pendingExtInf);
      if (parsed.name.isNotEmpty) name = parsed.name;
      duration = parsed.duration;
      logo = parsed.logo;
      groupTitle = parsed.groupTitle;
      tvgId = parsed.tvgId;
      tvgName = parsed.tvgName;
    }

    entries.add(
      M3uEntry(
        url: url,
        name: name,
        logo: logo,
        groupTitle: groupTitle,
        tvgId: tvgId,
        tvgName: tvgName,
        duration: duration,
      ),
    );
    pendingExtInf = null;
  }

  return entries;
}

bool _hasExtInf(List<String> lines) {
  for (final String line in lines) {
    if (line.trim().startsWith('#EXTINF')) return true;
  }
  return false;
}

/// Parseo de una línea `#EXTINF`.
ExtInf _parseExtInf(String line) {
  // Formato: #EXTINF:-1 tvg-id="x" tvg-name="y" tvg-logo="z" group-title="g",Nombre
  int duration = -1;
  String? logo;
  String? groupTitle;
  String? tvgId;
  String? tvgName;

  // Extrae la duración (primer token tras #EXTINF:).
  final int colonIdx = line.indexOf(':');
  final String afterColon = colonIdx >= 0
      ? line.substring(colonIdx + 1).trim()
      : line.substring('#EXTINF'.length).trim();

  final RegExp durationMatch = RegExp(r'^(-?\d+(?:\.\d+)?)');
  final Match? dur = durationMatch.firstMatch(afterColon);
  if (dur != null) {
    duration = double.tryParse(dur.group(1)!)?.round() ?? -1;
  }

  // Extrae key="value" (con posible comilla doble o simple).
  final RegExp attrRegex = RegExp(
    "([a-zA-Z0-9_-]+)=(\"[^\"]*\"|'[^']*'|[^\\s,]+)",
  );
  for (final RegExpMatch attr in attrRegex.allMatches(line)) {
    final String key = attr.group(1)!.toLowerCase();
    String value = attr.group(2)!;
    if (value.length >= 2 &&
        (value.startsWith('"') || value.startsWith('\'')) &&
        value.endsWith(value[0])) {
      value = value.substring(1, value.length - 1);
    }
    switch (key) {
      case 'tvg-id':
        tvgId = value;
        break;
      case 'tvg-name':
        tvgName = value;
        break;
      case 'tvg-logo':
        logo = value;
        break;
      case 'group-title':
        groupTitle = value;
        break;
    }
  }

  // El nombre es el texto tras la última coma (fuera de comillas de atributos).
  String name = _extractDisplayName(line);

  return ExtInf(
    duration: duration,
    logo: logo,
    groupTitle: groupTitle,
    tvgId: tvgId,
    tvgName: tvgName,
    name: name,
  );
}

/// Extrae el nombre de visualización de la línea `#EXTINF`.
///
/// El separador entre los atributos (`key="value"`) y el nombre es, según el
/// estándar M3U, la última coma que no está dentro de comillas. Este helper
/// rastrea la posición justo después de la última comilla de cierre de un
/// atributo y, si existe, lo usa como inicio del nombre (los nombres pueden
/// contener comas). Cae a la última coma sin comillas como aproximación.
String _extractDisplayName(String line) {
  int lastUnquotedComma = -1;
  bool inQuote = false;
  int quoteCode = 0;
  int afterLastQuote = -1;
  for (int i = 0; i < line.length; i++) {
    final int code = line.codeUnitAt(i);
    if (inQuote) {
      if (code == quoteCode) {
        inQuote = false;
        afterLastQuote = i + 1;
      }
    } else if (code == 34 || code == 39) {
      inQuote = true;
      quoteCode = code;
    } else if (code == 44) {
      lastUnquotedComma = i;
    }
  }
  if (afterLastQuote > 0) {
    // El nombre comienza tras la última comilla de cierre; elimina la coma
    // y espacios inmediatamente posteriores si existen.
    final String result = line.substring(afterLastQuote).trim();
    return result.replaceFirst(RegExp(r'^,\s*'), '').trim();
  }
  return lastUnquotedComma < 0
      ? ''
      : line.substring(lastUnquotedComma + 1).trim();
}

/// Resultado del análisis de una línea `#EXTINF`.
class ExtInf {
  const ExtInf({
    required this.duration,
    this.logo,
    this.groupTitle,
    this.tvgId,
    this.tvgName,
    required this.name,
  });

  final int duration;
  final String? logo;
  final String? groupTitle;
  final String? tvgId;
  final String? tvgName;
  final String name;
}

/// Ejecuta [parseM3u] en un isolate para no bloquear la UI.
Future<List<M3uEntry>> parseM3uInIsolate(String content) async {
  return Isolate.run<List<M3uEntry>>(() => parseM3u(content));
}
