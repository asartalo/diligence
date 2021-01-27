import 'package:flutter_test/flutter_test.dart';

final List<Function> integrationTests = [];

void addIntegrationTest(Function fn) {
  integrationTests.add(fn);
}

Future<void> callIntegrationTests() async {
  for (final fn in integrationTests) {
    if (fn is Future<void> Function()) {
      await fn();
    } else {
      fn();
    }
  }
}

Future<void> navigateToReminderPage(WidgetTester tester) async {
  await tester.pumpAndSettle();
  expect(find.text('Review'), findsOneWidget);
}
