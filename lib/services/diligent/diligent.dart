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

import 'package:sqlite_async/sqlite_async.dart';

import 'tasks/new_task.dart';
import '../../models/reminders/reminder.dart';
import '../../models/reminders/reminder_list.dart';
import 'tasks/task.dart';
import 'tasks/task_list.dart';
import 'tasks/task_node.dart';
import '../../models/task_pack.dart';
import '../../utils/clock.dart';
import 'focus_queue_manager.dart';
import 'reminders_repository.dart';
import 'task_db.dart';
import 'task_events/added_reminders_event.dart';
import 'task_events/removed_reminders_event.dart';
import 'task_events/task_event.dart';
import 'task_events/task_event_registry.dart';
import '../migrate.dart';
import 'tasks/tasks_db_reader.dart';
import 'transactions/transaction_factory.dart';

typedef TaskNodeList = List<TaskNode>;

class Diligent extends TaskDb {
  @override
  final SqliteDatabase db;

  final FocusQueueManager focusQueueManager;

  final Clock clock;

  final bool _isTest;

  final TransactionFactory _transactionFactory;

  final TaskEventRegistry _eventRegistry;

  final TasksDbReader _tasksRepositoryView;

  final RemindersRepository _remindersRepository;

  Diligent({
    required this.db,
    required bool isTest,
    required this.focusQueueManager,
    required this.clock,
    required TasksDbReader tasksRepositoryView,
    required TaskEventRegistry eventRegistry,
    required TransactionFactory transactionFactory,
    required RemindersRepository remindersRepository,
  }) : _isTest = isTest,
       _eventRegistry = eventRegistry,
       _transactionFactory = transactionFactory,
       _tasksRepositoryView = tasksRepositoryView,
       _remindersRepository = remindersRepository {
    focusQueueManager.registerEventHandlers(this);
  }

  Future<void> setUp() async {
    await db.execute('PRAGMA foreign_keys = ON');
    await migrations.migrate(db);
  }

  Future<void> clearDataForTests() async {
    if (_isTest) {
      await db.execute('DELETE FROM focusQueue');
      await db.execute('DELETE FROM reminders');
      await db.execute('DELETE FROM notices');
      await db.execute('DELETE FROM jobs');
      await db.execute('DELETE FROM tasks');
    }
  }

  void register<T extends TaskEvent>(TaskEventHandler<T> handler) {
    _eventRegistry.register(handler);
  }

  Future<void> announceEvent<T extends TaskEvent>(T event) async {
    await _eventRegistry.broadcast<T>(event);
  }

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

  Future<TaskList> addTasks(TaskList tasks, {int? position}) async {
    TaskList newTasks = [];

    await db.writeTransaction((tx) async {
      newTasks = await _transactionFactory
          .addTasks(tx)
          .work(tasks, position: position);
    });

    return newTasks;
  }

  Future<Task> addTask(Task task, {int? position}) async {
    final newTasks = await addTasks([task], position: position);

    if (newTasks.isEmpty) {
      throw Exception('Task was not created.');
    }

    return newTasks.first;
  }

  Future<Task?> findTask(int id) => _tasksRepositoryView.findTask(id);

  Future<Task?> findTaskByName(String name) =>
      _tasksRepositoryView.findTaskByName(name);

  Future<Task> updateTask(Task task) async {
    late Task? updatedTask;
    await db.writeTransaction((tx) async {
      updatedTask = await _transactionFactory.updateTask(tx).work(task);
    });

    return updatedTask!;
  }

  Future<TaskList> ancestors(Task task) => _tasksRepositoryView.ancestors(task);

  Future<TaskList> descendants(Task task) =>
      _tasksRepositoryView.descendants(task);

  Future<void> deleteTask(Task task) async {
    await db.writeTransaction(
      (tx) => _transactionFactory.deleteTask(tx).work(task),
    );
  }

  Future<void> moveTask(Task task, int position, {Task? parent}) async {
    await db.writeTransaction(
      (tx) =>
          _transactionFactory.moveTask(tx).work(task, position, parent: parent),
    );
  }

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

  FutureOr<TaskList> getChildren(Task task) =>
      _tasksRepositoryView.getChildren(task);

  FutureOr<Task?> getParent(Task task) => _tasksRepositoryView.getParent(task);

  /// Returns a task and its descendants as an ordered list
  Future<TaskNodeList> subtreeFlat(int id) =>
      _tasksRepositoryView.subtreeFlat(id);

  Future<TaskNodeList> expandedDescendantsTree(Task task) =>
      _tasksRepositoryView.expandedDescendantsTree(task);

  Future<TaskList> leaves(Task task) => _tasksRepositoryView.leaves([task]);

  Future<TaskList> focusQueue({int? limit}) =>
      focusQueueManager.focusQueue(limit: limit);

  Future<int> getFocusedCount() => focusQueueManager.getFocusedCount();

  Future<void> focus(Task task, {int position = 0}) =>
      focusQueueManager.focus(task, position: position);

  Future<void> focusTasks(TaskList tasks, {int position = 0}) =>
      focusQueueManager.focusTasks(tasks, position: position);

  Future<void> unfocus(Task task) => focusQueueManager.unfocus(task);

  Future<void> reprioritizeInFocusQueue(Task task, int position) =>
      focusQueueManager.reprioritizeInFocusQueue(task, position);

  Future<void> addReminders(List<Reminder> reminders) async {
    await db.writeTransaction((tx) async {
      final batchProps = reminders.map((reminder) {
        return [reminder.taskId, reminder.remindAt.millisecondsSinceEpoch];
      }).toList();

      await tx.executeBatch(
        'INSERT INTO reminders (taskId, remindAt) VALUES (?, ?)',
        batchProps,
      );
    });
    await announceEvent(AddedRemindersEvent(clock.now(), reminders: reminders));
  }

  Future<ReminderList> getNextReminders(DateTime now) =>
      _remindersRepository.getNextReminders(now);

  Future<ReminderList> getRemindersForTask(Task task) =>
      _remindersRepository.getRemindersForTask(task);

  Future<ReminderList> getRemindersForTaskIds(List<int> taskIds) =>
      _remindersRepository.getRemindersForTaskIds(taskIds);

  Future<Reminder> dismissReminder(Reminder reminder) async {
    if (clock.now().isBefore(reminder.remindAt)) {
      throw ReminderError('Cannot dismiss a reminder before it is due.');
    }

    final Reminder(:taskId, :remindAt) = reminder;
    await db.execute(
      '''
      UPDATE reminders
      SET dismissed = 1
      WHERE taskId = ? AND remindAt = ?
      ''',
      [taskId, remindAt.millisecondsSinceEpoch],
    );

    return reminder.dismiss();
  }

  Future<void> deleteReminders(List<Reminder> reminders) async {
    await db.executeBatch(
      '''
      DELETE FROM reminders
      WHERE taskId = ? AND remindAt = ?
      ''',
      reminders.map((reminder) {
        return [reminder.taskId, reminder.remindAt.millisecondsSinceEpoch];
      }).toList(),
    );
    await announceEvent(
      RemovedRemindersEvent(clock.now(), reminders: reminders),
    );
  }

  Future<TaskPack?> getTaskPackById(int id) async {
    final task = await findTask(id);

    if (task == null) {
      return null;
    }

    return TaskPack(task, reminders: await getRemindersForTask(task));
  }
}

class ReminderError extends Error {
  final String message;

  ReminderError(this.message);

  @override
  String toString() => 'ReminderError: $message';
}
