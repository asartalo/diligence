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

import 'package:collection/collection.dart';
import 'package:sqlite_async/sqlite_async.dart';

import '../../models/reminder_job.dart';
import '../../models/scheduled_job.dart';
import '../../utils/date_time_from_row_epoch.dart';
import '../diligent/reminders/reminder.dart';

class JobQueueReader {
  final SqliteReadContext tx;

  JobQueueReader({required this.tx});

  Future<ScheduledJob?> nextJob() async {
    final rows = await tx.getAll('''
      SELECT * FROM jobs
      ORDER BY runAt
      LIMIT 1
      ''');

    return rows.isEmpty ? null : _jobFromRow(rows.first);
  }

  Future<bool> isPending(ScheduledJob job) async {
    final rows = await tx.getAll('SELECT * FROM jobs WHERE uuid = ? LIMIT 1', [
      job.uuid,
    ]);

    return rows.isNotEmpty;
  }

  ScheduledJob _jobFromRow(Map<String, Object?> row) {
    final type = row['type'] as String;
    switch (type) {
      case 'reminder':
        return ReminderJob(
          uuid: row['uuid'] as String,
          runAt: dateTimeFromRowEpoch(row['runAt']),
          taskId: row['taskId'] as int,
        );
      default:
        throw Exception('Unknown job type: $type');
    }
  }

  Future<List<ScheduledJob>> queryJobsFromReminders(
    List<Reminder> reminders,
  ) async {
    final params = reminders
        .map(
          (reminder) => [
            reminder.remindAt.millisecondsSinceEpoch,
            reminder.taskId,
          ],
        )
        .flattened
        .toList();
    final queryQuestions = reminders.map((reminder) => '(?, ?)').join(', ');
    final query =
        '''
      SELECT * FROM jobs
      WHERE (runAt, taskId) IN ($queryQuestions)
      ''';
    final rows = await tx.getAll(query, params);
    return rows.map(_jobFromRow).toList();
  }
}
