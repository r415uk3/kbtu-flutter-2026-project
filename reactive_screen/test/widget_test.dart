import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:reactive_screen/main.dart';

void main() {
  testWidgets('tap card counts and reset dialog works', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Tap this card'));
    await tester.tap(find.text('Tap this card'));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);

    await tester.longPress(find.text('Tap this card'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);

    await tester.longPress(find.text('Tap this card'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset').last);
    await tester.pumpAndSettle();
    expect(find.text('2'), findsNothing);
  });

  testWidgets('minus is disabled at zero', (tester) async {
    await tester.pumpWidget(const MyApp());

    final minus = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, '−'),
    );
    expect(minus.onPressed, isNull);
  });
}
