import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kylora/core/utils/clock_format.dart';

void main() {
  final MaterialLocalizations l10n = const DefaultMaterialLocalizations();

  test('formatClockTime usa 24 h cuando el ajuste es 24 h', () {
    expect(
      formatClockTime(
        const TimeOfDay(hour: 18, minute: 5),
        clock24h: true,
        localizations: l10n,
      ),
      '18:05',
    );
    expect(
      formatClockTime(
        const TimeOfDay(hour: 0, minute: 0),
        clock24h: true,
        localizations: l10n,
      ),
      '00:00',
    );
  });

  test('formatClockTime usa 12 h con AM/PM cuando el ajuste es 12 h', () {
    expect(
      formatClockTime(
        const TimeOfDay(hour: 18, minute: 5),
        clock24h: false,
        localizations: l10n,
      ),
      '6:05 PM',
    );
    expect(
      formatClockTime(
        const TimeOfDay(hour: 0, minute: 5),
        clock24h: false,
        localizations: l10n,
      ),
      '12:05 AM',
    );
    expect(
      formatClockTime(
        const TimeOfDay(hour: 12, minute: 0),
        clock24h: false,
        localizations: l10n,
      ),
      '12:00 PM',
    );
  });
}
