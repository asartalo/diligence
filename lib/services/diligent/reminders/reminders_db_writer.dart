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

import 'package:sqlite_async/sqlite3.dart';
import 'package:sqlite_async/sqlite_async.dart';

import 'reminder.dart';
import 'reminder_list.dart';
import '../tasks/task.dart';
import '../../../utils/clock.dart';
import '../../../utils/date_time_from_row_epoch.dart';
import '../task_fields.dart';

class RemindersDbWriter {
  final Clock clock;

  final SqliteWriteContext _tx;

  RemindersDbWriter({required this.clock, required SqliteWriteContext tx})
    : _tx = tx;

  Future<ReminderList> getRemindersForTask(Task task) async {
    return getRemindersForTaskIds([task.id]);
  }

  Future<ReminderList> getNextReminders(DateTime now) async {
    final rows = await _tx.getAll(
      '''
      SELECT reminders.*
      FROM reminders
      WHERE reminders.remindAt <= ?
      ORDER BY reminders.remindAt ASC
      ''',
      [now.millisecondsSinceEpoch],
    );

    return ReminderList(rows.map(reminderFromRow).toList());
  }

  Future<ReminderList> getRemindersForTaskIds(List<int> taskIds) async {
    final rows = await _tx.getAll('''
      SELECT reminders.*
      FROM reminders
      WHERE reminders.taskId IN (${questionMarks(taskIds.length)})
      ORDER BY reminders.remindAt ASC
      ''', taskIds);

    return ReminderList(rows.map(reminderFromRow).toList());
  }

  Reminder reminderFromRow(Row row) {
    return Reminder(
      taskId: row['taskId'] as int,
      remindAt: dateTimeFromRowEpoch(row['remindAt']),
      dismissed: row['dismissed'] as int == 1,
    );
  }
}
