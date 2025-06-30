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

import '../di_scope_cache.dart';
import '../services/diligent/tasks_repository.dart';
import '../services/diligent/tasks_repository_view.dart';
import '../services/diligent/transactions/add_tasks.dart';
import '../services/diligent/transactions/delete_task.dart';
import '../services/diligent/transactions/update_task.dart';
import '../utils/clock.dart';
import 'app_state_scope.dart';

class TransactionScope {
  final AppStateScope parent;

  final SqliteWriteContext tx;

  final DiScopeCache _cache;

  Clock get clock => parent.clock;

  TransactionScope({required this.parent, required this.tx})
    : _cache = DiScopeCache();

  TasksRepository get tasksRepository => _cache.getSet(
    #tasksRepository,
    () => TasksRepository(clock: clock, tx: tx, view: tasksRepositoryView),
  );

  TasksRepositoryView get tasksRepositoryView => _cache.getSet(
    #tasksRepositoryView,
    () => TasksRepositoryView(clock: clock, tx: tx),
  );

  AddTasks get addTasks {
    return AddTasks(
      tx,
      clock: clock,
      eventRegistry: parent.taskEventRegistry,
      tasksRepository: tasksRepository,
    );
  }

  UpdateTask get updateTask {
    return UpdateTask(
      tx,
      clock: clock,
      eventRegistry: parent.taskEventRegistry,
      tasksRepository: tasksRepository,
    );
  }

  DeleteTask get deleteTask {
    return DeleteTask(
      tx,
      clock: clock,
      eventRegistry: parent.taskEventRegistry,
      tasksRepository: tasksRepository,
    );
  }
}
