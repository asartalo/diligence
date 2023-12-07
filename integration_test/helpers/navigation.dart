import 'package:flutter_test/flutter_test.dart';

Future<void> navigateToReminderPage(WidgetTester tester) async {
  await tester.pumpAndSettle();
  expect(find.text('Review'), findsOneWidget);
}
