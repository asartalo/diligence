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

import 'package:sqlite_async/sqlite_async.dart';

import '../../../di/app_state_scope.dart';
import '../../../di/transaction_scope.dart';
import 'add_tasks.dart';
import 'delete_task.dart';
import 'move_task.dart';
import 'update_task.dart';

class TransactionFactory {
  AppStateScope di;

  TransactionFactory(this.di);

  TransactionScope _newScope(SqliteWriteContext tx) {
    return TransactionScope(parent: di, tx: tx);
  }

  AddTasks addTasks(SqliteWriteContext tx) {
    return _newScope(tx).addTasks;
  }

  UpdateTask updateTask(SqliteWriteContext tx) {
    return _newScope(tx).updateTask;
  }

  DeleteTask deleteTask(SqliteWriteContext tx) {
    return _newScope(tx).deleteTask;
  }

  MoveTask moveTask(SqliteWriteContext tx) {
    return _newScope(tx).moveTask;
  }
}
