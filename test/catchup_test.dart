import 'package:flutter_test/flutter_test.dart';

import 'package:kylora/core/utils/catchup.dart';
import 'package:kylora/domain/entities/epg.dart';

EpgEntry _program(DateTime start, DateTime end) =>
    EpgEntry(title: 'Programa', start: start, end: end);

void main() {
  test('isCatchupAvailable solo acepta programas pasados del archivo', () {
    final DateTime now = DateTime(2026, 10, 28, 21);
    expect(
      isCatchupAvailable(
        hasArchive: true,
        archiveDurationDays: 1,
        program: _program(
          DateTime(2026, 10, 28, 19),
          DateTime(2026, 10, 28, 20),
        ),
        now: now,
      ),
      isTrue,
    );
    expect(
      isCatchupAvailable(
        hasArchive: false,
        archiveDurationDays: 1,
        program: _program(
          DateTime(2026, 10, 28, 19),
          DateTime(2026, 10, 28, 20),
        ),
        now: now,
      ),
      isFalse,
    );
    expect(
      isCatchupAvailable(
        hasArchive: true,
        archiveDurationDays: 1,
        program: _program(
          DateTime(2026, 10, 28, 20),
          DateTime(2026, 10, 28, 22),
        ),
        now: now,
      ),
      isFalse,
      reason: 'El programa aún no ha terminado',
    );
    expect(
      isCatchupAvailable(
        hasArchive: true,
        archiveDurationDays: 1,
        program: _program(
          DateTime(2026, 10, 26, 19),
          DateTime(2026, 10, 26, 20),
        ),
        now: now,
      ),
      isFalse,
      reason: 'Fuera de la ventana de archivo',
    );
  });

  test('formatCatchupStart usa el formato de Xtream', () {
    expect(formatCatchupStart(DateTime(2026, 1, 2, 3, 4)), '2026-01-02:03-04');
  });

  test('buildXtreamCatchupUrl usa la duración del programa', () {
    final String url = buildXtreamCatchupUrl(
      serverUrl: 'http://server:8080/',
      username: 'user name',
      password: 'p@ss',
      streamId: 42,
      program: _program(
        DateTime(2026, 10, 28, 19, 35),
        DateTime(2026, 10, 28, 20, 25),
      ),
    );
    expect(
      url,
      'http://server:8080/timeshift/user%20name/'
      'p%40ss/50/2026-10-28:19-35/42.ts',
    );
  });
}
