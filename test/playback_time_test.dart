import 'package:flutter_test/flutter_test.dart';

import 'package:kylora/core/utils/playback_time.dart';

void main() {
  test('playbackEndsAt suma el tiempo restante a la hora actual', () {
    final DateTime now = DateTime(2026, 1, 1, 18, 0);
    final DateTime endsAt = playbackEndsAt(
      now: now,
      position: const Duration(minutes: 10),
      duration: const Duration(minutes: 90),
    );
    expect(endsAt, DateTime(2026, 1, 1, 19, 20));
  });

  test('playbackEndsAt no devuelve una hora pasada si ya terminó', () {
    final DateTime now = DateTime(2026, 1, 1, 18, 0);
    final DateTime endsAt = playbackEndsAt(
      now: now,
      position: const Duration(minutes: 91),
      duration: const Duration(minutes: 90),
    );
    expect(endsAt, now);
  });

  test('playbackEndsAt se desplaza si el vídeo está en pausa', () {
    const Duration position = Duration(minutes: 10);
    const Duration duration = Duration(minutes: 90);
    // Pausa a las 18:00: quedan 80 min, termina a las 19:20.
    expect(
      playbackEndsAt(
        now: DateTime(2026, 1, 1, 18, 0),
        position: position,
        duration: duration,
      ),
      DateTime(2026, 1, 1, 19, 20),
    );
    // 10 minutos en pausa (18:10): los minutos restantes no cambian, pero la
    // hora de fin pasa a ser 19:30.
    expect(
      playbackEndsAt(
        now: DateTime(2026, 1, 1, 18, 10),
        position: position,
        duration: duration,
      ),
      DateTime(2026, 1, 1, 19, 30),
    );
  });
}
