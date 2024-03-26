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

import 'package:diligence/ui/screens/focus/keys.dart' as keys;
import 'package:diligence/ui/screens/tasks/task_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_screen.dart';
import 'test_screen_task_item_actions.dart';

@immutable
class TestFocusScreen extends TestScreen with TestScreenTaskItemActions {
  Finder get taskQueue => find.byKey(keys.focusQueueList);

  @override
  Finder get taskList => taskQueue;

  const TestFocusScreen(super.dtest);

  Iterable<TaskItem> _taskItemsOnQueue() {
    return dtest.tester.widgetList<TaskItem>(find.descendant(
      of: taskQueue,
      matching: find.byType(TaskItem),
    ));
  }

  Future<void> deleteTask(String name) async {
    await tapTaskMenuDelete(name);
  }

  Future<void> editTask(
    String currentName, {
    String? name,
    String? details,
  }) async {
    await tapTaskMenuEdit(currentName);
    await inputTaskDetails(name: name, details: details);
  }

  Future<void> expectFocusQueue(List<String> taskNames) async {
    final taskItems = _taskItemsOnQueue();
    final actual = taskItems.map((taskItem) => taskItem.task.name).toList();

    expect(
      actual,
      taskNames,
      reason: 'Items on Focus Queue did not match',
    );
  }

  Future<void> unfocusTask(String name) async {
    await tapTaskMenuUnfocus(name);
  }
}
