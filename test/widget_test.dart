import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kylora/app.dart';
import 'package:kylora/presentation/screens/dashboard/dashboard_screen.dart';

void main() {
  testWidgets('Arranca y muestra el dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const KyloraApp());
    await tester.pumpAndSettle();

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byIcon(Icons.live_tv), findsOneWidget);
  });
}