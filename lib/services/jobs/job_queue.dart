import 'package:collection/collection.dart';
import 'package:sqlite_async/sqlite_async.dart';

import '../../models/reminder_job.dart';
import '../../models/reminders/reminder.dart';
import '../../models/scheduled_job.dart';
import '../../utils/clock.dart';
import '../../utils/date_time_from_row_epoch.dart';
import '../../utils/logger.dart';
import '../../utils/stringers.dart';
import '../diligent.dart';
import '../diligent/diligent_event_register.dart';
import '../diligent/task_events/added_reminders_event.dart';
import '../diligent/task_events/removed_reminders_event.dart';
import '../migrate.dart';

typedef Pass<T> = String Function(T item);

extension CommaIt<T> on Iterable<T> {
  String mapComma(Pass<T> pass) => map(pass).commas();

  String commas() => join(', ');

  String questions() => map((_) => '?').join(', ');
}

class JobQueue implements DiligentEventRegister {
  final SqliteDatabase db;
  final Clock clock;
  final bool _isTest;
  final List<NextJobListener> nextJobListeners = [];
  final Logger logger;

  JobQueue._internal({
    required bool isTest,
    required this.db,
    required this.logger,
    Clock? clock,
  })  : _isTest = isTest,
        clock = clock ?? Clock();

  factory JobQueue({
    required SqliteDatabase db,
    required Logger logger,
    Clock? clock,
  }) {
    return JobQueue._internal(
      db: db,
      isTest: false,
      logger: logger,
      clock: clock,
    );
  }

  factory JobQueue.forTests({
    required SqliteDatabase db,
    required Logger logger,
    Clock? clock,
  }) {
    return JobQueue._internal(
      db: db,
      isTest: true,
      logger: logger,
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

  List<Object?> _jobFieldValues(ScheduledJob job) {
    List<Object?> fieldValues = [];
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
    return fieldValues;
  }

  Future<void> addJob(ScheduledJob job) async {
    logger.info('Adding job: ${job.runtimeType} ${job.uuid}');
    await _addJobs([job], db);
  }

  Future<void> _addJobs(List<ScheduledJob> jobs, SqliteWriteContext tx) async {
    final nextBefore = await _nextJob(tx);
    final fieldValuesList = jobs.map(_jobFieldValues).toList();
    await tx.executeBatch(
      'INSERT INTO jobs (uuid, runAt, type, taskId) VALUES (?, ?, ?, ?)',
      fieldValuesList,
    );

    final nextAfter = await _nextJob(tx);
    if (nextAfter is ScheduledJob && nextBefore != nextAfter) {
      _broadcastNextJob(nextAfter);
    }
  }

  Future<void> _broadcastNextJob(ScheduledJob job) async {
    for (final listener in nextJobListeners) {
      await listener.handleNextJobUpdate(job);
    }
  }

  Future<ScheduledJob?> nextJob() async {
    return _nextJob(db);
  }

  Future<ScheduledJob?> _nextJob(SqliteReadContext tx) async {
    final rows = await tx.getAll(
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
      'SELECT * FROM jobs WHERE uuid = ? LIMIT 1',
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
          runAt: dateTimeFromRowEpoch(row['runAt']),
          taskId: row['taskId'] as int,
        );
      default:
        throw Exception('Unknown job type: $type');
    }
  }

  Future<void> completeJob(ScheduledJob job) async {
    await _completeJobs([job]);
  }

  Future<void> _completeJobs(List<ScheduledJob> jobs) async {
    if (jobs.isEmpty) return;
    await db.writeTransaction((tx) async {
      logger.debug('Completing jobs:\n${newlineJoin(jobs, padding: '  - ')}');
      final uuids = jobs.map((job) => [job.uuid]).toList();
      final nextBefore = await _nextJob(tx);
      await tx.executeBatch('DELETE FROM jobs WHERE uuid = ?', uuids);

      final nextAfter = await _nextJob(tx);
      if (nextAfter is ScheduledJob && nextBefore != nextAfter) {
        _broadcastNextJob(nextAfter);
      }
    });
  }

  Future<void> handleAddedRemindersEvent(AddedRemindersEvent event) async {
    logger.debug(
      'handleAddedRemindersEvent()\n${newlineJoin(event.reminders, padding: '  - ')}',
    );
    final jobs = await _newJobsFromReminders(event.reminders);
    _addJobs(jobs, db);
  }

  Future<void> handleRemovedRemindersEvent(RemovedRemindersEvent event) async {
    logger.debug(
      'handleRemovedRemindersEvent()\n${newlineJoin(event.reminders, padding: '  - ')}',
    );
    final jobs = await _queryJobsFromReminders(event.reminders);
    _completeJobs(jobs);
  }

  Future<List<ScheduledJob>> _newJobsFromReminders(
      List<Reminder> reminders) async {
    return reminders
        .map((reminder) => ReminderJob(
              runAt: reminder.remindAt,
              taskId: reminder.taskId,
            ))
        .toList();
  }

  Future<List<ScheduledJob>> _queryJobsFromReminders(
    List<Reminder> reminders,
  ) async {
    final params = reminders
        .map((reminder) =>
            [reminder.remindAt.millisecondsSinceEpoch, reminder.taskId])
        .flattened
        .toList();
    final queryQuestions = reminders.map((reminder) => '(?, ?)').join(', ');
    final query = '''
      SELECT * FROM jobs
      WHERE (runAt, taskId) IN ($queryQuestions)
      ''';
    final rows = await db.getAll(
      query,
      params,
    );
    return rows.map(_jobFromRow).toList();
  }

  @override
  void registerEventHandlers(Diligent diligent) {
    diligent.register(handleAddedRemindersEvent);
    diligent.register(handleRemovedRemindersEvent);
  }
}

abstract class NextJobListener {
  Future<void> handleNextJobUpdate(ScheduledJob job);
}
