import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kylora/presentation/shared_widgets/tv_focusable.dart';
import 'package:kylora/presentation/shared_widgets/tv_marquee_text.dart';

void main() {
  testWidgets('TvMarqueeText sólo desplaza el título de la tarjeta enfocada', (
    WidgetTester tester,
  ) async {
    final FocusNode first = FocusNode(debugLabel: 'first-card');
    final FocusNode second = FocusNode(debugLabel: 'second-card');
    final Key firstKey = UniqueKey();
    final Key secondKey = UniqueKey();
    addTearDown(first.dispose);
    addTearDown(second.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Row(
              children: <Widget>[
                SizedBox(
                  key: firstKey,
                  width: 90,
                  child: TvFocusable(
                    focusNode: first,
                    child: const TvMarqueeText(
                      text: 'Canal con un nombre larguísimo que no cabe',
                      maxLines: 1,
                      pixelsPerSecond: 1000,
                    ),
                  ),
                ),
                SizedBox(
                  key: secondKey,
                  width: 90,
                  child: TvFocusable(
                    focusNode: second,
                    child: const TvMarqueeText(
                      text: 'Otro canal con un nombre larguísimo que no cabe',
                      maxLines: 1,
                      pixelsPerSecond: 1000,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    Finder marqueeTransform(Key cardKey) => find.descendant(
      of: find.descendant(
        of: find.byKey(cardKey),
        matching: find.byType(TvMarqueeText),
      ),
      matching: find.byType(Transform),
    );

    expect(marqueeTransform(firstKey), findsNothing);
    expect(marqueeTransform(secondKey), findsNothing);

    first.requestFocus();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 700));

    expect(marqueeTransform(firstKey), findsOneWidget);
    expect(marqueeTransform(secondKey), findsNothing);

    final Transform firstTransform = tester.widget<Transform>(
      marqueeTransform(firstKey),
    );
    expect(firstTransform.transform.getTranslation().x, lessThan(0));

    second.requestFocus();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(marqueeTransform(firstKey), findsNothing);
    expect(marqueeTransform(secondKey), findsOneWidget);
  });
}
