import 'package:flutter_test/flutter_test.dart';

import 'interactions.dart';

Future<void> navigateToReminderPage(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tapByStringKey(tester, 'appBarMenuButton');
  await tapByStringKey(tester, 'drawerLinkReview');
  expect(find.text('Review'), findsOneWidget);
}
