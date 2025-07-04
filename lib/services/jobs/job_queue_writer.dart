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

import '../../models/reminder_job.dart';
import '../../models/scheduled_job.dart';
import '../../utils/stringers.dart';
import '../diligent/reminders/reminder.dart';
import '../logger/logger.dart';
import 'job_queue_reader.dart';

class JobQueueWriter {
  final SqliteWriteContext _tx;
  final JobQueueReader reader;
  final Logger logger;

  JobQueueWriter({
    required SqliteWriteContext tx,
    required this.reader,
    required this.logger,
  }) : _tx = tx {
    if (!identical(_tx, reader.tx)) {
      throw ArgumentError('reader.tx should be the same instance as _tx');
    }
  }

  Future<ScheduledJob?> addJobs(List<ScheduledJob> jobs) async {
    final nextBefore = await reader.nextJob();
    final fieldValuesList = jobs.map(_jobFieldValues).toList();
    await _tx.executeBatch(
      'INSERT INTO jobs (uuid, runAt, type, taskId) VALUES (?, ?, ?, ?)',
      fieldValuesList,
    );

    final nextAfter = await reader.nextJob();
    if (nextAfter is ScheduledJob && nextBefore != nextAfter) {
      return nextAfter;
    }

    return null;
  }

  Future<ScheduledJob?> completeJobs(List<ScheduledJob> jobs) async {
    if (jobs.isNotEmpty) {
      logger.debug('Completing jobs:\n${newlineJoin(jobs, padding: '  - ')}');
      final uuids = jobs.map((job) => [job.uuid]).toList();
      final nextBefore = await reader.nextJob();
      await _tx.executeBatch('DELETE FROM jobs WHERE uuid = ?', uuids);

      final nextAfter = await reader.nextJob();
      if (nextAfter is ScheduledJob && nextBefore != nextAfter) {
        return nextAfter;
      }
    }

    return null;
  }

  List<Object?> _jobFieldValues(ScheduledJob job) {
    List<Object?> fieldValues = [];
    switch (job) {
      case ReminderJob(
        uuid: final uid,
        runAt: final runAt,
        taskId: final taskId,
      ):
        fieldValues = [uid, runAt.millisecondsSinceEpoch, 'reminder', taskId];
        break;
    }
    return fieldValues;
  }

  Future<List<ScheduledJob>> queryJobsFromReminders(
    List<Reminder> reminders,
  ) async {
    return reader.queryJobsFromReminders(reminders);
  }

  Future<List<ScheduledJob>> newJobsFromReminders(
    List<Reminder> reminders,
  ) async {
    return reminders
        .map(
          (reminder) =>
              ReminderJob(runAt: reminder.remindAt, taskId: reminder.taskId),
        )
        .toList();
  }
}
