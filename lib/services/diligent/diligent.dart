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

import 'dart:async';

import 'tasks/new_task.dart';
import 'tasks/task.dart';
import 'tasks/task_list.dart';
import 'tasks/task_node.dart';
import '../../models/task_pack.dart';
import '../../utils/clock.dart';
import 'reminders/reminders.dart';
import 'sqlite_backend.dart';

typedef TaskNodeList = List<TaskNode>;

class Diligent {
  final Clock clock;

  final bool _isTest;

  final SqliteBackend _backend;

  Diligent({
    required bool isTest,
    required this.clock,
    required SqliteBackend backend,
  }) : _isTest = isTest,
       _backend = backend;

  Future<void> setUp() => _backend.setUp();

  Future<void> clearDataForTests() => _backend.clearDataForTests(_isTest);

  NewTask newTask({
    int id = 0,
    int? parentId,
    Task? parent,
    bool? done,
    DateTime? doneAt,
    String? uid,
    String? name,
    String? details,
    bool? expanded,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deadlineAt,
    DateTime? now,
  }) {
    return NewTask(
      id: id,
      parentId: parentId,
      parent: parent,
      doneAt: doneAt,
      uid: uid,
      name: name ?? '',
      details: details,
      expanded: expanded ?? false,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deadlineAt: deadlineAt,
      now: now ?? clock.now(),
    );
  }

  Future<TaskList> addTasks(TaskList tasks, {int? position}) =>
      _backend.addTasks(tasks, position: position);

  Future<Task> addTask(Task task, {int? position}) async {
    final newTasks = await addTasks([task], position: position);

    if (newTasks.isEmpty) {
      throw Exception('Task was not created.');
    }

    return newTasks.first;
  }

  Future<Task?> findTask(int id) => _backend.findTask(id);

  Future<Task?> findTaskByName(String name) => _backend.findTaskByName(name);

  Future<Task> updateTask(Task task) => _backend.updateTask(task);

  Future<TaskList> ancestors(Task task) => _backend.ancestors(task);

  Future<TaskList> descendants(Task task) => _backend.descendants(task);

  Future<void> deleteTask(Task task) => _backend.deleteTask(task);

  Future<void> moveTask(Task task, int position, {Task? parent}) =>
      _backend.moveTaskTx(task, position, parent: parent);

  Future<void> initialAreas(TaskList areas) async {
    final root = await findTask(1);

    if (root != null) {
      return;
    }

    await addTask(newTask(name: 'Root', id: 1, uid: 'root', expanded: true));
    final now = clock.now();
    for (final area in areas) {
      await addTask(
        area.copyWith(parentId: 1, updatedAt: now, createdAt: now, now: now),
      );
    }
  }

  FutureOr<TaskList> getChildren(Task task) => _backend.getChildren(task);

  FutureOr<Task?> getParent(Task task) => _backend.getParent(task);

  /// Returns a task and its descendants as an ordered list
  Future<TaskNodeList> subtreeFlat(int id) => _backend.subtreeFlat(id);

  Future<TaskNodeList> expandedDescendantsTree(Task task) =>
      _backend.expandedDescendantsTree(task);

  Future<TaskList> leaves(Task task) => _backend.leaves(task);

  Future<TaskList> focusQueue({int? limit}) =>
      _backend.focusQueue(limit: limit);

  Future<int> getFocusedCount() => _backend.getFocusedCount();

  Future<void> focus(Task task, {int position = 0}) =>
      _backend.focus(task, position: position);

  Future<void> focusTasks(TaskList tasks, {int position = 0}) =>
      _backend.focusTasks(tasks, position: position);

  Future<void> unfocus(Task task) => _backend.unfocus(task);

  Future<void> reprioritizeInFocusQueue(Task task, int position) =>
      _backend.reprioritizeInFocusQueue(task, position);

  Future<void> addReminders(List<Reminder> reminders) =>
      _backend.addReminders(reminders);

  Future<ReminderList> getNextReminders(DateTime now) =>
      _backend.getNextReminders(now);

  Future<ReminderList> getRemindersForTask(Task task) =>
      _backend.getRemindersForTask(task);

  Future<ReminderList> getRemindersForTaskIds(List<int> taskIds) =>
      _backend.getRemindersForTaskIds(taskIds);

  Future<Reminder> dismissReminder(Reminder reminder) =>
      _backend.dismissReminder(reminder);

  Future<void> deleteReminders(List<Reminder> reminders) =>
      _backend.deleteReminders(reminders);

  Future<TaskPack?> getTaskPackById(int id) async {
    final task = await findTask(id);

    if (task == null) {
      return null;
    }

    return TaskPack(task, reminders: await getRemindersForTask(task));
  }
}
