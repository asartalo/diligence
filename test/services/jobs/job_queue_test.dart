import 'package:diligence/models/reminder_job.dart';
import 'package:diligence/models/scheduled_job.dart';
import 'package:diligence/services/jobs/job_queue.dart';
import 'package:diligence/utils/clock.dart';
import 'package:diligence/utils/stub_clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_async/sqlite_async.dart';

import '../../helpers/stub_logger.dart';

void main() {
  group('JobScheduler', () {
    late StubListener listener;
    late JobQueue jobScheduler;
    late Clock clock;
    final startNow = DateTime(2024, 4, 12, 16);

    setUp(() async {
      listener = StubListener();
      clock = StubClock(startNow);
      // Tests run in parallel so make each test file unique
      final testDb = SqliteDatabase(path: 'test_job_scheduler.db');
      jobScheduler = JobQueue.forTests(
        db: testDb,
        clock: clock,
        logger: StubLogger(),
      );
      jobScheduler.registerNextJobListener(listener);
      await jobScheduler.runMigrations();
    });

    tearDown(() => jobScheduler.clearDataForTests());

    group('When adding some jobs', () {
      late ScheduledJob job1, job2, job3;
      final runAt = DateTime(2024, 4, 13, 16);

      setUp(() async {
        const taskId = 2;
        final anHourBefore = runAt.subtract(const Duration(hours: 1));
        job1 = ReminderJob(runAt: runAt, taskId: taskId);
        job2 = ReminderJob(runAt: anHourBefore, taskId: taskId);
        job3 = ReminderJob(
          runAt: runAt.add(const Duration(hours: 1)),
          taskId: taskId,
        );

        for (final job in [job1, job2, job3]) {
          await jobScheduler.addJob(job);
        }
      });

      test('should be able to add jobs', () async {
        expect(await jobScheduler.nextJob(), job2);
      });

      test('should notify listeners when a new job is added', () async {
        expect(listener.nextJobsSet, [job1, job2]);
      });

      test('uncompleted jobs are still pending', () async {
        expect(await jobScheduler.isPending(job1), isTrue);
      });

      group('when the nextJob is completed', () {
        setUp(() async {
          job2 = (await jobScheduler.nextJob())!;
          await jobScheduler.completeJob(job2);
        });

        test('the nextJob should point to the next one in the queue', () async {
          expect(await jobScheduler.nextJob(), job1);
        });

        test('should notify listeners of a new next job', () async {
          await jobScheduler.completeJob(job2);
          expect(listener.nextJobsSet.last, job1);
        });

        test('completed job is no longer pending', () async {
          expect(await jobScheduler.isPending(job2), isFalse);
        });
      });

      group('when an earlier job is added', () {
        late ReminderJob earliestJob;

        setUp(() async {
          listener.reset();
          earliestJob = ReminderJob(
            runAt: job2.runAt.subtract(const Duration(seconds: 5)),
            taskId: 3,
          );
          await jobScheduler.addJob(earliestJob);
        });

        test('should be able to update next job', () async {
          expect(await jobScheduler.nextJob(), earliestJob);
        });

        test('should notify next job listeners of this earlier job', () async {
          expect(listener.nextJobsSet.last, earliestJob);
        });
      });

      group('when an later job is added', () {
        late ReminderJob lateJob;

        setUp(() async {
          listener.reset();
          lateJob = ReminderJob(
            runAt: job2.runAt.add(const Duration(seconds: 5)),
            taskId: 3,
          );
          await jobScheduler.addJob(lateJob);
        });

        test('should not update next job', () async {
          expect(await jobScheduler.nextJob(), job2);
        });

        test('should notify not next job listeners of this job', () async {
          expect(listener.nextJobsSet, isEmpty);
        });
      });
    });
  });
}

class StubListener implements NextJobListener {
  List<ScheduledJob> nextJobsSet = [];

  @override
  Future<void> handleNextJobUpdate(ScheduledJob job) async {
    nextJobsSet.add(job);
  }

  void reset() {
    nextJobsSet = [];
  }
}
