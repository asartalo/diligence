import 'package:diligence/ui/components/keys.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dtest_base.dart';

mixin DtestNavigation implements DtestBase {
  Future<void> tapOnMenuBarItem(Key key) async {
    await pumpAndSettle();
    await tapByKey(appBarMenuButton);
    await tapByKey(key);
  }

  Future<void> navigateToReminderPage() async {
    await tapOnMenuBarItem(drawerLinkReview);
    expect(find.text('Review'), findsOneWidget);
  }

  Future<void> navigateToTasksPage() async {
    await tapOnMenuBarItem(drawerLinkTasks);
    expect(find.text('Tasks'), findsOneWidget);
  }
}
