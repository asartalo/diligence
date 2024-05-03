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

import 'package:date_field/date_field.dart';
import 'package:diligence/ui/screens/tasks/keys.dart' as keys;
import 'package:diligence/ui/components/keys.dart' as compkeys;
import 'package:diligence/ui/screens/tasks/task_item.dart';
import 'package:diligence/utils/i18n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_screen.dart';
import 'test_screen_task_item_actions.dart';

@immutable
class TestTasksScreen extends TestScreen with TestScreenTaskItemActions {
  @override
  Finder get taskList => find.byKey(keys.mainTaskList);

  const TestTasksScreen(super.dtest);

  // Creates a task on the current ancestor
  //
  // On the tasks page, the default would be the Root task.
  Future<void> createTaskOnCurrentAncestor(
    String name, {
    String? details,
  }) async {
    await dtest.tapByKey(keys.addTaskFloatingButton);
    await dtest.enterTextByKey(keys.taskNameField, name);
    if (details is String) {
      await dtest.enterTextByKey(keys.taskDetailsField, details);
    }
    await dtest.tapByKey(keys.saveTaskButton);
  }

  Future<void> addChildTask(String name, {required String parent}) async {
    await tapTaskMenuAdd(parent);
    await inputTaskDetails(name: name);
  }

  Future<void> editTask(
    String currentName, {
    String? name,
    String? details,
  }) async {
    await tapTaskMenuEdit(currentName);
    await inputTaskDetails(name: name, details: details);
  }

  Future<void> editTaskViaTaskView(
    String currentName, {
    String? name,
    String? details,
  }) async {
    await showTask(currentName);
    await inputTaskDetails(name: name, details: details);
  }

  Future<void> deleteTaskViaTaskView(String name) async {
    await showTask(name);
    await dtest.tapByKey(keys.deleteTaskButton);
  }

  Future<void> deleteTask(String name) async {
    await tapTaskMenuDelete(name);
  }

  Future<void> focusTask(String name) async {
    await tapTaskMenuFocus(name);
  }

  Future<void> addReminder(String name, DateTime date) async {
    await showTask(name);
    await dtest.tapByKey(keys.addReminderButton);
    await setReminderDate(date);
    await dtest.tapByKey(keys.saveTaskButton);
  }

  Future<void> setReminderDate(DateTime date) async {
    final tester = dtest.tester;
    final widget = tester.widget<DateTimeFormField>(
      find.byKey(keys.reminderDateField),
    );
    // TODO: The following is a hack. Learn how to do it properly.
    widget.onChanged!(date);
    await dtest.tapByKey(keys.reminderAddButton);
  }

  Future<void> removeReminder(String name, DateTime date) async {
    await showTask(name);
    final remindersSection = find.byKey(keys.remindersSection);
    final whenText = dateTimeFormat.format(date);
    final reminderText = find.descendant(
      of: remindersSection,
      matching: find.text(whenText),
    );
    final reminderItem = find.ancestor(
      of: reminderText,
      matching: find.byType(ListTile),
    );
    final deleteButton = find.descendant(
      of: reminderItem,
      matching: find.byKey(keys.reminderDeleteButton),
    );
    await dtest.tapElement(deleteButton);
  }

  // Expectations //

  void expectTaskExistsOnTaskList(
    String name, {
    String? details,
  }) {
    final task = findTaskItem(name);
    expect(
      task,
      findsOneWidget,
      reason: 'Did not find task item with name: "$name"',
    );
    if (details is String) {
      final taskDetails = find.descendant(
        of: task,
        matching: find.byKey(keys.taskItemDetails),
      );
      expect(
        taskDetails,
        findsOneWidget,
        reason: 'Did not find task details for task: "$name"',
      );
      final detailsWidget = dtest.tester.firstWidget<Text>(taskDetails);
      expect(detailsWidget.data, details, reason: 'Task details do not match');
    }
  }

  void expectTaskDoesNotExistOnTaskList(String name) {
    expect(
      findTaskItem(name),
      findsNothing,
      reason: 'Found task item "$name" when it should not be.',
    );
  }

  Iterable<TaskItem> _taskItemsOnTaskList() {
    return dtest.tester.widgetList<TaskItem>(find.descendant(
      of: taskList,
      matching: find.byType(TaskItem),
    ));
  }

  void expectTaskIsChildOfParent(String name, {required String parent}) {
    final taskItems = _taskItemsOnTaskList();
    TaskItem? parentTaskItem;
    TaskItem? childTaskItem;
    int? parentLevel;
    int? childLevel;

    for (final taskItem in taskItems) {
      final currentLevel = taskItem.level;
      if (parentLevel is int) {
        final pLevel = parentLevel;
        // Start tracking
        if (currentLevel! <= pLevel) {
          fail('Did not find child task "$name" under parent task "$parent"');
        }
        if (currentLevel > pLevel + 1) {
          continue;
        }
      }
      if (taskItem.task.name == name) {
        if (parentTaskItem == null) {
          fail('Found child "$name" before we could find parent "$parent"');
        }
        childTaskItem = taskItem;
        childLevel = currentLevel;
        break;
      }

      if (taskItem.task.name == parent) {
        parentTaskItem = taskItem;
        parentLevel = currentLevel;
      }
    }

    if (childTaskItem == null) {
      fail('Did not find child task "$name"');
    }
    if (childLevel is! int || parentLevel is! int) {
      fail('Did not find appropriate levels for parent and child tasks');
    }
  }

  String _spacesPerLevel(int level) {
    return '  ' * level;
  }

  void expectTaskLayout(List<String> expected) {
    final taskItems = _taskItemsOnTaskList();
    final List<String> actual = [];

    for (final taskItem in taskItems) {
      final level = taskItem.level;
      if (level is int) {
        actual.add('${_spacesPerLevel(level)}${taskItem.task.name}');
      } else {
        actual.add(taskItem.task.name);
      }
    }

    expect(actual, expected);
  }

  Checkbox findTaskCheckboxWidget(String name) {
    final checkboxFinder = findTaskCheckbox(name);
    return tester.firstWidget<Checkbox>(checkboxFinder);
  }

  void expectTaskIsDone(String name) {
    final checkbox = findTaskCheckboxWidget(name);

    expect(checkbox.value, true);
  }

  void expectTaskIsNotDone(String name) {
    final checkbox = findTaskCheckboxWidget(name);

    expect(checkbox.value, false);
  }

  Finder _reminderItem(String name, DateTime when) {
    final remindersSection = find.byKey(keys.remindersSection);
    return find.descendant(
      of: remindersSection,
      matching: find.text(dateTimeFormat.format(when)),
    );
  }

  void expectToSeeReminder(String name, DateTime when) {
    final whenText = dateTimeFormat.format(when);
    expect(
      _reminderItem(name, when),
      findsOneWidget,
      reason: 'Did not find reminder for task "$name" at "$whenText"',
    );
  }

  void expectNotToSeeReminder(String name, DateTime when) {
    final whenText = dateTimeFormat.format(when);
    expect(
      _reminderItem(name, when),
      findsNothing,
      reason: 'Found reminder for task "$name" at "$whenText" unexpectedly.',
    );
  }

  Finder _reminderNotice(String name) {
    final noticeArea = find.byKey(compkeys.noticeArea);
    return find.descendant(
      of: noticeArea,
      matching: find.text('Reminder: $name'),
    );
  }

  void expectNotToSeeReminderNotice(String name) {
    final notice = _reminderNotice(name);
    expect(
      notice,
      findsNothing,
      reason: 'Found reminder notice for task "$name"',
    );
  }

  void expectToSeeReminderNotice(String name) {
    final notice = _reminderNotice(name);
    expect(
      notice,
      findsOneWidget,
      reason: 'Did not find reminder notice for task "$name"',
    );
  }
}
