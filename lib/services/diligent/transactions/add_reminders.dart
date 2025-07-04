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

import '../../../models/scheduled_job.dart';
import '../../jobs/job_queue_writer.dart';
import '../../jobs/job_track.dart';
import '../../../utils/clock.dart';
import '../reminders/reminder.dart';

class AddReminders {
  final SqliteWriteContext tx;

  final JobQueueWriter jobQueueWriter;

  final JobTrack jobTrack;

  final Clock clock;

  AddReminders(
    this.tx, {
    required this.clock,
    required this.jobQueueWriter,
    required this.jobTrack,
  });

  Future<void> work(List<Reminder> reminders) async {
    final batchProps = reminders.map((reminder) {
      return [reminder.taskId, reminder.remindAt.millisecondsSinceEpoch];
    }).toList();

    await tx.executeBatch(
      'INSERT INTO reminders (taskId, remindAt) VALUES (?, ?)',
      batchProps,
    );

    final jobs = await jobQueueWriter.newJobsFromReminders(reminders);
    final nextJob = await jobQueueWriter.addJobs(jobs);
    // TODO: Find out if this could some jobs in jobTrack to linger
    if (nextJob is ScheduledJob) {
      jobTrack.handleNextJobUpdate(nextJob);
    }
  }
}
