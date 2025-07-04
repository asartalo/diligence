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

import 'package:sqlite_async/sqlite_async.dart';

import '../services/diligent/tasks/tasks.dart';
import '../services/diligent/transactions/transactions.dart';
import '../services/jobs/job_queue_reader.dart';
import '../services/jobs/job_queue_writer.dart';
import '../utils/clock.dart';
import 'app_state_scope.dart';
import 'read_tx_scope.dart';

// Write Transaction Scope
class WriteTxScope {
  final AppStateScope parent;

  final SqliteWriteContext tx;

  Clock get clock => parent.clock;

  WriteTxScope({required this.parent, required this.tx});

  ReadTxScope? _readScope;
  ReadTxScope get readScope =>
      _readScope ??= ReadTxScope(parent: parent, tx: tx, clock: clock);

  TasksDbWriter? _tasksWriter;
  TasksDbWriter get tasksWriter =>
      _tasksWriter ??= TasksDbWriter(clock: clock, tx: tx, view: tasksReader);

  TasksDbReader get tasksReader => readScope.tasksReader;

  AddTasks? _addTasks;
  AddTasks get addTasks => _addTasks ??= AddTasks(
    tx,
    clock: clock,
    tasksDbWriter: tasksWriter,
    focusQueueManager: parent.focusQueueManager,
  );

  UpdateTask? _updateTask;
  UpdateTask get updateTask => _updateTask ??= UpdateTask(
    tx,
    clock: clock,
    tasksDbWriter: tasksWriter,
    focusQueueManager: parent.focusQueueManager,
  );

  DeleteTask? _deleteTask;
  DeleteTask get deleteTask => _deleteTask ??= DeleteTask(
    tx,
    clock: clock,
    tasksDbWriter: tasksWriter,
    focusQueueManager: parent.focusQueueManager,
  );

  MoveTask? _moveTask;
  MoveTask get moveTask => _moveTask ??= MoveTask(
    tx,
    clock: clock,
    tasksDbWriter: tasksWriter,
    focusQueueManager: parent.focusQueueManager,
  );

  AddReminders? _addReminders;
  AddReminders get addReminders => _addReminders ??= AddReminders(
    tx,
    jobQueueWriter: jobQueueWriter,
    jobTrack: parent.jobTrack,
    clock: clock,
  );

  DismissReminder? _dismissReminder;
  DismissReminder get dismissReminder =>
      _dismissReminder ??= DismissReminder(tx, clock: clock);

  JobQueueReader? _jobQueueReader;
  JobQueueReader get jobQueueReader =>
      _jobQueueReader ??= JobQueueReader(tx: tx);

  JobQueueWriter? _jobQueueWriter;
  JobQueueWriter get jobQueueWriter => _jobQueueWriter ??= JobQueueWriter(
    tx: tx,
    reader: jobQueueReader,
    logger: parent.jobQueueLogger,
  );

  DeleteReminders? _deleteReminders;
  DeleteReminders get deleteReminders => _deleteReminders ??= DeleteReminders(
    tx,
    jobQueueWriter: jobQueueWriter,
    jobTrack: parent.jobTrack,
  );
}
