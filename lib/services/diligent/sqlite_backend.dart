// Diligence - A Task Management App
//
// Copyright (C) 2025 Wayne Duran <asartalo@gmail.com>
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

import '../../utils/clock.dart';
import '../migrate.dart';
import 'diligent.dart';
import 'focus_queue_manager.dart';
import 'reminders/reminder.dart';
import 'reminders/reminder_list.dart';
import 'reminders/reminders_db_reader.dart';
import 'sqlite_backend_common.dart';
import 'tasks/tasks.dart';

class SqliteBackend {
  final SqliteDatabase _db;
  final WriteTxScopeFn _writeTxFn;
  final ReadTxScopeFn _readTxFn;
  final TasksDbReader _tasksReader;
  final FocusQueueManager _focusQueueManager;
  final RemindersDbReader _remindersReader;
  final Clock clock;

  SqliteBackend({
    required SqliteDatabase db,
    required WriteTxScopeFn writeTxFn,
    required ReadTxScopeFn readTxFn,
    required TasksDbReader tasksReader,
    required FocusQueueManager focusQueueManager,
    required RemindersDbReader remindersReader,
    required this.clock,
  }) : _db = db,
       _writeTxFn = writeTxFn,
       _readTxFn = readTxFn,
       _tasksReader = tasksReader,
       _focusQueueManager = focusQueueManager,
       _remindersReader = remindersReader;

  Future<T> writeScoped<T>(WriteScopedFn<T> fn) {
    return _db.writeTransaction((tx) => fn(_writeTxFn(tx)));
  }

  Future<T> readScoped<T>(ReadScopedFn<T> fn) {
    return _db.readTransaction((tx) => fn(_readTxFn(tx)));
  }

  Future<void> setUp() async {
    await _db.execute('PRAGMA foreign_keys = ON');
    await migrations.migrate(_db);
  }

  Future<void> clearDataForTests(bool isTest) async {
    if (isTest) {
      await _db.writeTransaction((tx) async {
        await tx.execute('DELETE FROM focusQueue');
        await tx.execute('DELETE FROM reminders');
        await tx.execute('DELETE FROM notices');
        await tx.execute('DELETE FROM jobs');
        await tx.execute('DELETE FROM tasks');
      });
    }
  }

  Future<Task?> findTask(int id) => _tasksReader.findTask(id);

  Future<Task?> findTaskByName(String name) =>
      _tasksReader.findTaskByName(name);

  FutureOr<TaskList> getChildren(Task task) => _tasksReader.getChildren(task);

  FutureOr<Task?> getParent(Task task) => _tasksReader.getParent(task);

  Future<TaskList> ancestors(Task task) => _tasksReader.ancestors(task);

  Future<TaskList> descendants(Task task) => _tasksReader.descendants(task);

  Future<TaskNodeList> subtreeFlat(int id) => _tasksReader.subtreeFlat(id);

  Future<TaskNodeList> expandedDescendantsTree(Task task) =>
      _tasksReader.expandedDescendantsTree(task);

  Future<TaskList> leaves(Task task) => _tasksReader.leaves([task]);

  Future<TaskList> addTasks(TaskList tasks, {int? position}) =>
      writeScoped((scope) => scope.addTasks.work(tasks, position: position));

  Future<Task> updateTask(Task task) =>
      writeScoped((scope) => scope.updateTask.work(task));

  Future<void> deleteTask(Task task) =>
      writeScoped((scope) => scope.deleteTask.work(task));

  Future<void> moveTaskTx(Task task, int position, {Task? parent}) =>
      writeScoped(
        (scope) => scope.moveTask.work(task, position, parent: parent),
      );

  Future<TaskList> focusQueue({int? limit}) =>
      _focusQueueManager.focusQueue(limit: limit);

  Future<int> getFocusedCount() => _focusQueueManager.getFocusedCount();

  Future<void> focus(Task task, {int position = 0}) =>
      _focusQueueManager.focus(task, position: position);

  Future<void> focusTasks(TaskList tasks, {int position = 0}) =>
      _focusQueueManager.focusTasks(tasks, position: position);

  Future<void> reprioritizeInFocusQueue(Task task, int position) =>
      _focusQueueManager.reprioritizeInFocusQueue(task, position);

  Future<void> unfocus(Task task) => _focusQueueManager.unfocus(task);

  Future<ReminderList> getNextReminders(DateTime now) =>
      _remindersReader.getNextReminders(now);

  Future<ReminderList> getRemindersForTask(Task task) =>
      _remindersReader.getRemindersForTask(task);

  Future<ReminderList> getRemindersForTaskIds(List<int> taskIds) =>
      _remindersReader.getRemindersForTaskIds(taskIds);

  Future<void> addReminders(List<Reminder> reminders) =>
      writeScoped((scope) => scope.addReminders.work(reminders));

  Future<Reminder> dismissReminder(Reminder reminder) =>
      writeScoped((scope) => scope.dismissReminder.work(reminder));

  Future<void> deleteReminders(List<Reminder> reminders) =>
      writeScoped((scope) => scope.deleteReminders.work(reminders));
}
