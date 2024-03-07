import 'package:diligence/ui/screens/tasks/keys.dart' as keys;
import 'package:diligence/ui/screens/tasks/task_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dtest.dart';

@immutable
class TestTasksScreenTest {
  final Dtest dtest;

  Finder get taskList => find.byKey(keys.mainTaskList);
  WidgetTester get tester => dtest.tester;

  const TestTasksScreenTest(this.dtest);

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

  Future<void> inputTaskDetails({
    String? name,
    String? details,
  }) async {
    if (name is String) {
      await dtest.enterTextByKey(keys.taskNameField, name);
    }
    if (details is String) {
      await dtest.enterTextByKey(keys.taskDetailsField, details);
    }
    await dtest.tapByKey(keys.saveTaskButton);
  }

  Future<void> tapTaskMenuItem(String name, Key key) async {
    final task = findTaskItem(name);
    final menuButton = find.descendant(
      of: task,
      matching: find.byKey(keys.taskMenu),
    );
    await dtest.tapElement(menuButton);
    final button = find.descendant(
      of: task,
      matching: find.byKey(key),
    );
    await dtest.tapElement(button);
  }

  Future<void> tapTaskMenuAdd(String name) =>
      tapTaskMenuItem(name, keys.taskMenuAdd);

  Future<void> tapTaskMenuDelete(String name) =>
      tapTaskMenuItem(name, keys.taskMenuDelete);

  Future<void> tapTaskMenuEdit(String name) =>
      tapTaskMenuItem(name, keys.taskMenuEdit);

  Future<void> addChildTask(String name, {required String parent}) async {
    await tapTaskMenuAdd(parent);
    await inputTaskDetails(name: name);
  }

  Finder findTaskItem(String name) {
    final taskNameText = find.descendant(
      of: taskList,
      matching: find.text(name),
    );

    return find.ancestor(of: taskNameText, matching: find.byKey(keys.taskItem));
  }

  Future<void> showTask(String name) async {
    final task = findTaskItem(name);
    await dtest.tapElement(task);
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
    await showTask(name);
    await dtest.tapByKey(keys.deleteTaskButton);
  }

  Future<void> moveTask(
    String name, {
    required String to,
    Duration? duration,
  }) async {
    final task = findTaskItem(name);
    final destination = findTaskItem(to);
    final fromCoords = tester.getCenter(task);
    final toCoords = tester.getCenter(destination);
    await dtest.longPressThenDrag(
      fromCoords,
      toCoords.translate(
        0,
        // Offset so we make sure to get past the destination
        fromCoords.dy > toCoords.dy ? 5 : -5,
      ),
      duration: duration,
    );
  }

  // Expectations

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
}
