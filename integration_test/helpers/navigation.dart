import 'package:diligence/ui/components/keys.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'interactions.dart';

Future<void> tapOnMenuBarItem(WidgetTester tester, Key key) async {
  await tester.pumpAndSettle();
  await tapByKey(tester, appBarMenuButton);
  await tapByKey(tester, key);
}

Future<void> navigateToReminderPage(WidgetTester tester) async {
  await tapOnMenuBarItem(tester, drawerLinkReview);
  expect(find.text('Review'), findsOneWidget);
}

Future<void> navigateToTasksPage(WidgetTester tester) async {
  await tapOnMenuBarItem(tester, drawerLinkTasks);
  expect(find.text('Tasks'), findsOneWidget);
}
