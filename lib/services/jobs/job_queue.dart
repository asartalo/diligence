import 'package:sqlite_async/sqlite_async.dart';

import '../../models/scheduled_job.dart';
import '../../utils/clock.dart';
import '../logger/logger.dart';
import '../migrate.dart';
import 'job_queue_reader.dart';
import 'job_queue_writer.dart';

typedef Pass<T> = String Function(T item);

extension CommaIt<T> on Iterable<T> {
  String mapComma(Pass<T> pass) => map(pass).commas();

  String commas() => join(', ');

  String questions() => map((_) => '?').join(', ');
}

class JobQueue {
  final SqliteDatabase db;
  final Clock clock;
  final bool _isTest;
  final List<NextJobListener> nextJobListeners = [];
  final Logger logger;

  JobQueue._internal({
    required bool isTest,
    required this.db,
    required this.logger,
    required this.clock,
  }) : _isTest = isTest;

  factory JobQueue({
    required SqliteDatabase db,
    required Logger logger,
    Clock? clock,
  }) {
    return JobQueue._internal(
      db: db,
      isTest: false,
      logger: logger,
      clock: clock ?? Clock(),
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
      clock: clock ?? Clock(),
    );
  }

  JobQueueReader queueReader(SqliteReadContext tx) {
    return JobQueueReader(tx: tx);
  }

  JobQueueWriter queueWriter(SqliteWriteContext tx) {
    return JobQueueWriter(tx: tx, reader: queueReader(tx), logger: logger);
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
    logger.info('Adding job: ${job.runtimeType} ${job.uuid}');
    await _addJobs([job], db);
  }

  Future<void> _addJobs(List<ScheduledJob> jobs, SqliteWriteContext tx) async {
    final nextAfter = await queueWriter(tx).addJobs(jobs);

    if (nextAfter is ScheduledJob) {
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

  Future<ScheduledJob?> _nextJob(SqliteReadContext tx) =>
      queueReader(tx).nextJob();

  Future<bool> isPending(ScheduledJob job) => queueReader(db).isPending(job);

  Future<void> completeJob(ScheduledJob job) async {
    await _completeJobs([job]);
  }

  Future<void> _completeJobs(List<ScheduledJob> jobs) async {
    if (jobs.isEmpty) return;
    await db.writeTransaction((tx) async {
      final nextAfter = await queueWriter(tx).completeJobs(jobs);

      if (nextAfter is ScheduledJob) {
        _broadcastNextJob(nextAfter);
      }
    });
  }
}

abstract class NextJobListener {
  Future<void> handleNextJobUpdate(ScheduledJob job);
}
