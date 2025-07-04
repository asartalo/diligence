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

import '../../../utils/clock.dart';
import '../reminders/reminder.dart';

class ReminderError extends Error {
  final String message;

  ReminderError(this.message);

  @override
  String toString() => 'ReminderError: $message';
}

class DismissReminder {
  final SqliteWriteContext tx;

  final Clock clock;

  DismissReminder(this.tx, {required this.clock});

  Future<Reminder> work(Reminder reminder) async {
    if (clock.now().isBefore(reminder.remindAt)) {
      throw ReminderError('Cannot dismiss a reminder before it is due.');
    }

    final Reminder(:taskId, :remindAt) = reminder;
    await tx.execute(
      '''
      UPDATE reminders
      SET dismissed = 1
      WHERE taskId = ? AND remindAt = ?
      ''',
      [taskId, remindAt.millisecondsSinceEpoch],
    );

    return reminder.dismiss();
  }
}
