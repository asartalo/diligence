import 'dart:io';

import 'package:diligence/ui/components/keys.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../../app.dart' as app;
import 'dtest_base.dart';
import 'test_tasks_screen.dart';

// ignore_for_file: avoid-dynamic

void integrationTest(String description, void Function() fn) {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group(description, () {
    tearDown(() async {
      await Future<void>.delayed(const Duration(seconds: 1));
    });

    setUp(() async {
      final file = File('test.db');
      if (await file.exists()) {
        await file.delete();
      }
    });

    fn();
  });
}

class Dtest extends DtestBase {
  Dtest(super.tester);

  Future<void> tapOnMenuBarItem(Key key) async {
    await pumpAndSettle();
    await tapByKey(appBarMenuButton);
    await tapByKey(key);
  }

  Future<void> navigateToReminderPage() async {
    await tapOnMenuBarItem(drawerLinkReview);
    expect(find.text('Review'), findsOneWidget);
  }

  Future<TestTasksScreenTest> navigateToTasksPage() async {
    await tapOnMenuBarItem(drawerLinkTasks);
    expect(find.text('Tasks'), findsOneWidget);
    return TestTasksScreenTest(this);
  }
}

typedef TestAppCallback = Future<void> Function(Dtest dtest);

void testApp(
  String description,
  TestAppCallback callback, {
  dynamic tags,
  bool? skip,
}) {
  testWidgets(
    description,
    (widgetTester) async {
      await app.main();

      return callback(Dtest(widgetTester));
    },
    tags: tags,
    skip: skip,
  );
}

typedef SetUpCallback = Future<void> Function(Dtest dtest);
