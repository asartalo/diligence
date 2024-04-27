import 'package:clock/clock.dart';
import 'package:sqlite_async/sqlite_async.dart';

import 'di_scope_cache.dart';
import 'models/reminder_job.dart';
import 'models/scheduled_job.dart';
import 'services/diligent.dart';
import 'services/jobs/hello_job_runner.dart';
import 'services/jobs/job_queue.dart';
import 'services/jobs/job_track.dart';
import 'services/jobs/reminder_job_runner.dart';

class Di {
  final String dbPath;

  final Clock clock;

  final bool isTest;

  Di({
    this.dbPath = 'diligence.db',
    Clock? clock,
    this.isTest = false,
  }) : clock = clock ?? const Clock();

  final DiScopeCache _cache = DiScopeCache();

  Diligent get diligent => _cache.getSet(
      #diligent,
      () => Diligent.convenience(
            isTest: isTest,
            db: db,
            clock: clock,
          ));

  SqliteDatabase get db =>
      _cache.getSet(#db, () => SqliteDatabase(path: dbPath));

  RunnerFactoryFunc get runnerFactoryFunc => (ScheduledJob inputJob) {
        switch (inputJob) {
          case HelloJob _:
            return helloJobRunner;
          case ReminderJob _:
            return reminderJobRunner;
          default:
            throw ArgumentError('Unknown job type: ${inputJob.runtimeType}');
        }
      };

  HelloJobRunner get helloJobRunner =>
      _cache.getSet(#helloJobRunner, () => HelloJobRunner());

  ReminderJobRunner get reminderJobRunner =>
      _cache.getSet(#reminderJobRunner, () => ReminderJobRunner());

  JobQueue get jobQueue => _cache.getSet(
        #jobQueue,
        () => isTest
            ? JobQueue.forTests(db: db, clock: clock)
            : JobQueue(db: db, clock: clock),
      );

  JobTrack get jobTrack => _cache.getSet(
        #jobTrack,
        () => JobTrack(
          clock: clock,
          runnerFactoryFunc: runnerFactoryFunc,
          jobQueue: jobQueue,
        ),
      );
}
