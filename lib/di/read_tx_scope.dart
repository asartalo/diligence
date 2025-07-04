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

import '../services/diligent/reminders/reminders.dart';
import '../services/diligent/tasks/tasks.dart';
import '../utils/clock.dart';
import 'app_state_scope.dart';

class ReadTxScope {
  final Clock clock;

  final AppStateScope parent;

  final SqliteReadContext tx;

  ReadTxScope({required this.parent, required this.tx, required this.clock});

  TasksDbReader? _tasksReader;
  TasksDbReader get tasksReader => _tasksReader ??= TasksDbReader(tx: tx);

  RemindersDbReader? _remindersDbReader;
  RemindersDbReader get remindersDbReader =>
      _remindersDbReader ??= RemindersDbReader(clock: clock, tx: tx);
}
