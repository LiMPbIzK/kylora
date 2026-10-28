import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kylora/presentation/shared_widgets/tv_focusable.dart';

void main() {
  testWidgets('TvFocusable: OK corto activa y OK largo abre la acción larga', (
    WidgetTester tester,
  ) async {
    int pressed = 0;
    int longPressed = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: TvFocusable(
              autofocus: true,
              onPressed: () => pressed++,
              onLongPress: () => longPressed++,
              child: const SizedBox(width: 120, height: 120),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Pulsación corta: se activa al soltar y no dispara la acción larga.
    await tester.sendKeyDownEvent(LogicalKeyboardKey.select);
    await tester.pump(const Duration(milliseconds: 100));
    expect(pressed, 0);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.select);
    await tester.pump();
    expect(pressed, 1);
    expect(longPressed, 0);

    // Pulsación mantenida: la acción larga se dispara al soltar y no activa.
    await tester.sendKeyDownEvent(LogicalKeyboardKey.select);
    await tester.pump(const Duration(milliseconds: 700));
    expect(longPressed, 0);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.select);
    await tester.pump();
    expect(longPressed, 1);
    expect(pressed, 1);
  });
}
