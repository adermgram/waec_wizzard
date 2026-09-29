import 'package:flutter_test/flutter_test.dart';

import 'package:waec_wizzard/main.dart';

void main() {
  testWidgets('Home screen shows the two practice modes', (WidgetTester tester) async {
    await tester.pumpWidget(const WaecWizardApp());

    expect(find.text('WAEC Wizard'), findsOneWidget);
    expect(find.text('Practice Quiz'), findsOneWidget);
    expect(find.text('Theory & Past Papers'), findsOneWidget);
  });
}
