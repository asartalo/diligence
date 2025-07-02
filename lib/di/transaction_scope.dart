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
import '../services/diligent/transactions/add_tasks.dart';
import '../services/diligent/transactions/delete_task.dart';
import '../services/diligent/transactions/move_task.dart';
import '../services/diligent/transactions/update_task.dart';
import '../utils/clock.dart';
import 'app_state_scope.dart';

class TransactionScope {
  final AppStateScope parent;

  final SqliteWriteContext tx;

  Clock get clock => parent.clock;

  TransactionScope({required this.parent, required this.tx});

  TasksDbWriter? _tasksWriter;
  TasksDbWriter get tasksWriter =>
      _tasksWriter ??= TasksDbWriter(clock: clock, tx: tx, view: tasksReader);

  TasksDbReader? _tasksReader;
  TasksDbReader get tasksReader => _tasksReader ??= TasksDbReader(tx: tx);

  AddTasks get addTasks {
    return AddTasks(
      tx,
      clock: clock,
      eventRegistry: parent.taskEventRegistry,
      tasksRepository: tasksWriter,
    );
  }

  UpdateTask get updateTask {
    return UpdateTask(
      tx,
      clock: clock,
      eventRegistry: parent.taskEventRegistry,
      tasksRepository: tasksWriter,
    );
  }

  DeleteTask get deleteTask {
    return DeleteTask(
      tx,
      clock: clock,
      eventRegistry: parent.taskEventRegistry,
      tasksRepository: tasksWriter,
    );
  }

  MoveTask get moveTask {
    return MoveTask(
      tx,
      clock: clock,
      eventRegistry: parent.taskEventRegistry,
      tasksRepository: tasksWriter,
    );
  }
}
