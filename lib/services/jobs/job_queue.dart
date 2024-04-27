import 'package:clock/clock.dart';
import 'package:sqlite_async/sqlite_async.dart';

import '../../models/reminder_job.dart';
import '../../models/scheduled_job.dart';
import '../migrate.dart';

class JobQueue {
  final SqliteDatabase db;
  final Clock clock;
  final bool _isTest;
  final List<NextJobListener> nextJobListeners = [];

  JobQueue._internal({
    required bool isTest,
    required this.db,
    Clock? clock,
  })  : _isTest = isTest,
        clock = clock ?? const Clock();

  factory JobQueue({
    required SqliteDatabase db,
    Clock? clock,
  }) {
    return JobQueue._internal(
      db: db,
      isTest: false,
      clock: clock,
    );
  }

  factory JobQueue.forTests({
    required SqliteDatabase db,
    Clock? clock,
  }) {
    return JobQueue._internal(
      db: db,
      isTest: true,
      clock: clock,
    );
  }

  Future<void> runMigrations() async {
    await migrations.migrate(db);
  }

  Future<void> clearDataForTests() async {
    if (_isTest) {
      await db.execute('DELETE FROM jobs');
    }
  }

  Future<void> registerNextJobListener(NextJobListener listener) async {
    nextJobListeners.add(listener);
  }

  Future<void> addJob(ScheduledJob job) async {
    List<Object> fieldValues = [];
    switch (job) {
      case ReminderJob(
          uuid: final uid,
          runAt: final runAt,
          taskId: final taskId
        ):
        fieldValues = [
          uid,
          runAt.millisecondsSinceEpoch,
          'reminder',
          taskId,
        ];
        break;
    }
    await db.execute(
      'INSERT INTO jobs (uuid, runAt, type, taskId) VALUES (?, ?, ?, ?)',
      fieldValues,
    );

    final uid = job.uuid;
    final next = await nextJob();
    if (uid == next?.uuid) {
      _broadcastNextJob(job);
    }
  }

  Future<void> _broadcastNextJob(ScheduledJob job) async {
    for (final listener in nextJobListeners) {
      await listener.handleNextJobUpdate(job);
    }
  }

  Future<ScheduledJob?> nextJob() async {
    final rows = await db.getAll(
      '''
      SELECT * FROM jobs
      ORDER BY runAt
      LIMIT 1
      ''',
    );

    return rows.isEmpty ? null : _jobFromRow(rows.first);
  }

  Future<bool> isPending(ScheduledJob job) async {
    final rows = await db.getAll(
      ' SELECT * FROM jobs WHERE uuid = ? LIMIT 1',
      [job.uuid],
    );

    return rows.isNotEmpty;
  }

  ScheduledJob _jobFromRow(Map<String, Object?> row) {
    final type = row['type'] as String;
    switch (type) {
      case 'reminder':
        return ReminderJob(
          uuid: row['uuid'] as String,
          runAt: DateTime.fromMillisecondsSinceEpoch(row['runAt'] as int),
          taskId: row['taskId'] as int,
        );
      default:
        throw Exception('Unknown job type: $type');
    }
  }

  Future<void> completeJob(ScheduledJob job) async {
    final uuid = job.uuid;
    final currentNextJob = await nextJob();
    await db.execute(
      'DELETE FROM jobs WHERE uuid = ?',
      [uuid],
    );
    if (currentNextJob?.uuid == uuid) {
      final newNextJob = await nextJob();
      if (newNextJob != null) {
        _broadcastNextJob(newNextJob);
      }
    }
  }
}

abstract class NextJobListener {
  Future<void> handleNextJobUpdate(ScheduledJob job);
}
