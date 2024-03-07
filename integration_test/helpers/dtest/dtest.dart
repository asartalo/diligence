import 'dart:io';

import 'package:diligence/models/new_task.dart';
import 'package:diligence/services/diligent.dart';
import 'package:diligence/ui/components/keys.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../../app.dart' as app;
import 'dtest_base.dart';
import 'test_focus_screen.dart';
import 'test_tasks_screen.dart';

// ignore_for_file: avoid-dynamic

class TestSetupTaskParam {
  final String name;
  final String? details;
  final String? parent;
  final bool? done;

  const TestSetupTaskParam(
    this.name, {
    this.details,
    this.parent,
    this.done,
  });
}

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
  Dtest(super.tester, {required super.container});

  Future<void> tapOnMenuBarItem(Key key) async {
    await pumpAndSettle();
    await tapByKey(appBarMenuButton);
    await tapByKey(key);
  }

  Future<void> navigateToReminderPage() async {
    await tapOnMenuBarItem(drawerLinkReview);
    expect(find.text('Review'), findsOneWidget);
  }

  Future<TestTasksScreen> navigateToTasksPage() async {
    await tapOnMenuBarItem(drawerLinkTasks);
    expect(find.text('Tasks'), findsOneWidget);
    return TestTasksScreen(this);
  }

  Future<TestFocusScreen> navigateToFocusPage() async {
    await tapOnMenuBarItem(drawerLinkFocus);
    expect(find.text('Focus'), findsOneWidget);
    return TestFocusScreen(this);
  }

  Future<void> setUpInitialTasks(List<TestSetupTaskParam> taskParams) async {
    final byParent = <String, List<TestSetupTaskParam>>{};
    // gather tasks by parent
    for (final taskParam in taskParams) {
      byParent[taskParam.parent ?? ''] ??= <TestSetupTaskParam>[];
      byParent[taskParam.parent ?? '']!.add(taskParam);
    }

    for (final children in byParent.entries) {
      final parent = await diligent.findTaskByName(children.key);
      final parentId = parent?.id;
      await diligent.addTasks(
        children.value.map((child) {
          return NewTask(
            name: child.name,
            details: child.details,
            parentId: parentId,
            doneAt: child.done != null ? DateTime.now() : null,
          );
        }).toList(),
      );
    }
  }

  Future<void> setUpFocusedTasks(List<String> taskNames) async {
    final TaskList tasks = [];
    for (final taskName in taskNames) {
      tasks.add((await diligent.findTaskByName(taskName))!);
    }
    await diligent.focusTasks(tasks);
  }

  Future<void> expandTasks(List<String> taskNames) async {
    for (final taskName in taskNames) {
      final task = await diligent.findTaskByName(taskName);
      if (task != null) {
        await diligent.updateTask(task.copyWith(expanded: true));
      }
    }
  }

  Future<void> longPressThenDrag(
    Offset start,
    Offset end, {
    Duration? duration,
  }) async {
    final TestGesture gesture = await tester.startGesture(start);
    // Long press first
    await tester.pump(kLongPressTimeout + kPressTimeout);

    // Sometimes the drag does not work so duration is needed because there are
    // intervening events that have to fire first somehow.
    // TODO: Investigate why this is the case and report it if necessary
    if (duration is Duration) {
      const frequency = 60.0;
      final int intervals = duration.inMicroseconds * frequency ~/ 1E6;
      final offset = end - start;

      final List<Duration> timeStamps = <Duration>[
        for (int t = 0; t <= intervals; t += 1) duration * t ~/ intervals,
      ];
      final List<Offset> offsets = <Offset>[
        start,
        for (int t = 0; t <= intervals; t += 1)
          start + offset * (t / intervals),
      ];
      await tester.pump(kLongPressTimeout + kPressTimeout);

      for (int i = 0; i < timeStamps.length; i++) {
        await gesture.moveTo(offsets[i]);
        await tester.pump();
      }
    } else {
      await gesture.moveTo(end);
      await tester.pump();
    }

    await gesture.up();
    await tester.pumpAndSettle();
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
      final container = await app.main();

      return callback(Dtest(widgetTester, container: container));
    },
    tags: tags,
    skip: skip,
  );
}

typedef SetUpCallback = Future<void> Function(Dtest dtest);
