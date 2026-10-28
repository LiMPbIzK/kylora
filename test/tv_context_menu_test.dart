import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kylora/presentation/shared_widgets/tv_context_menu.dart';

void main() {
  testWidgets('showTvContextMenu enfoca la primera opción al abrirse', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) => Center(
              child: FilledButton(
                onPressed: () => showTvContextMenu<String>(
                  context: context,
                  entries: const <TvContextMenuEntry<String>>[
                    TvContextMenuEntry<String>(
                      value: 'play',
                      icon: Icons.play_arrow,
                      label: 'Play',
                    ),
                    TvContextMenuEntry<String>(
                      value: 'favorite',
                      icon: Icons.favorite,
                      label: 'Favorite',
                    ),
                  ],
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final ListTile firstItem = tester.widget<ListTile>(
      find.ancestor(of: find.text('Play'), matching: find.byType(ListTile)),
    );
    expect(firstItem.focusNode?.hasFocus, isTrue);
  });
}
