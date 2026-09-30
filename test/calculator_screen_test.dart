import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waec_wizzard/features/calculator/calculator_screen.dart';

void main() {
  Future<void> pumpCalculator(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CalculatorScreen()));
  }

  Future<void> tapAndSettle(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pump();
  }

  String displayText(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('calculator_display'))).data!;

  testWidgets('typing 7 + 8 = shows 15', (tester) async {
    await pumpCalculator(tester);

    await tapAndSettle(tester, '7');
    await tapAndSettle(tester, '+');
    await tapAndSettle(tester, '8');
    await tapAndSettle(tester, '=');

    expect(displayText(tester), '15');
    expect(find.text('7+8'), findsOneWidget);
  });

  testWidgets('AC clears the display back to 0', (tester) async {
    await pumpCalculator(tester);

    await tapAndSettle(tester, '5');
    await tapAndSettle(tester, 'AC');

    expect(displayText(tester), '0');
  });

  testWidgets('sin(30) in DEG mode shows 0.5', (tester) async {
    await pumpCalculator(tester);

    expect(find.text('DEG'), findsOneWidget);

    await tapAndSettle(tester, 'sin');
    await tapAndSettle(tester, '3');
    await tapAndSettle(tester, '0');
    await tapAndSettle(tester, '=');

    expect(displayText(tester), '0.5');
  });

  testWidgets('malformed expression shows Error instead of crashing', (tester) async {
    await pumpCalculator(tester);

    await tapAndSettle(tester, '÷');
    await tapAndSettle(tester, '=');

    expect(displayText(tester), 'Error');
  });

  testWidgets('no button renders with a blank label', (tester) async {
    await pumpCalculator(tester);

    for (final textWidget in tester.widgetList<Text>(find.byType(Text))) {
      expect(textWidget.data, isNotNull);
      expect(textWidget.data!.trim(), isNotEmpty, reason: 'A button or label rendered blank text');
    }
  });

  testWidgets('typing ( and ) builds a parenthesized expression', (tester) async {
    await pumpCalculator(tester);

    expect(find.text('('), findsOneWidget);
    expect(find.text(')'), findsOneWidget);

    await tapAndSettle(tester, '(');
    await tapAndSettle(tester, '2');
    await tapAndSettle(tester, '+');
    await tapAndSettle(tester, '3');
    await tapAndSettle(tester, ')');
    await tapAndSettle(tester, '=');

    expect(displayText(tester), '5');
  });
}
