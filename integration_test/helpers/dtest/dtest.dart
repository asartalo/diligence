// Diligence - A Task Management App
//
// Copyright (C) 2024 Wayne Duran <asartalo@gmail.com>
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// this program. If not, see <https://www.gnu.org/licenses/>.

import 'package:diligence/models/new_task.dart';
import 'package:diligence/models/task_list.dart';
import 'package:diligence/ui/components/keys.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meta/meta.dart';

import '../../app.dart' as app;
import 'dtest_base.dart';
import 'test_focus_screen.dart';
import 'test_tasks_screen.dart';

// ignore_for_file: avoid-dynamic

class SetupTaskParam {
  final String name;
  final String? details;
  final String? parent;
  final bool? done;

  const SetupTaskParam(
    this.name, {
    this.details,
    this.parent,
    this.done,
  });
}

void integrationTest(String description, void Function() fn) {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group(description, fn);
}

class Dtest extends DtestBase {
  Dtest(super.tester, {required super.container});

  Future<void> tapOnMenuBarItem(Key key) async {
    await pumpAndSettle();
    await tapByKey(appBarMenuButton);
    await tapByKey(key);
  }

  Future<void> navigateToReminderScreen() async {
    await tapOnMenuBarItem(drawerLinkReview);
    expect(find.text('Review'), findsOneWidget);
  }

  Future<TestTasksScreen> navigateToTasksScreen() async {
    await tapOnMenuBarItem(drawerLinkTasks);
    expect(find.text('Tasks'), findsOneWidget);
    return TestTasksScreen(this);
  }

  Future<TestFocusScreen> navigateToFocusScreen() async {
    await tapOnMenuBarItem(drawerLinkFocus);
    expect(find.text('Focus'), findsOneWidget);
    return TestFocusScreen(this);
  }

  Future<void> navigateToSettingsScreen() async {
    await tapOnMenuBarItem(drawerLinkSettings);
    expect(find.text('Settings'), findsAtLeast(1));
  }

  Future<void> setUpInitialTasks(List<SetupTaskParam> taskParams) async {
    final byParent = <String, List<SetupTaskParam>>{};
    // gather tasks by parent
    for (final taskParam in taskParams) {
      byParent[taskParam.parent ?? ''] ??= <SetupTaskParam>[];
      byParent[taskParam.parent ?? '']!.add(taskParam);
    }

    for (final children in byParent.entries) {
      final parent = await diligent.findTaskByName(children.key);
      final parentId = parent?.id;
      await diligent.addTasks(
        children.value.map((child) {
          final now = clock.now();
          return NewTask(
            name: child.name,
            details: child.details,
            parentId: parentId,
            doneAt: child.done != null ? now : null,
            now: now,
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
        await diligent.updateTask(task.copyWith(
          expanded: true,
          now: clock.now(),
        ));
      }
    }
  }

  Future<void> waitSeconds(int seconds) async {
    await tester.pumpAndSettle(Duration(seconds: seconds));
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

@isTest
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
      await widgetTester.pumpAndSettle();
      final result = await callback(Dtest(widgetTester, container: container));

      return result;
    },
    tags: tags,
    skip: skip,
  );
}

typedef SetUpCallback = Future<void> Function(Dtest dtest);
