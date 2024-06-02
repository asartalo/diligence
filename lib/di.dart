import 'package:sqlite_async/sqlite_async.dart';

import 'di_scope_cache.dart';
import 'diligence_config.dart';
import 'models/notices/error_notice.dart';
import 'models/notices/notice.dart';
import 'models/notices/reminder_notice.dart';
import 'models/reminder_job.dart';
import 'models/scheduled_job.dart';
import 'services/diligent.dart';
import 'services/jobs/job_queue.dart';
import 'services/jobs/job_track.dart';
import 'services/jobs/reminder_job_runner.dart';
import 'services/notices/notice_queue.dart';
import 'utils/clock.dart';
import 'utils/fs.dart';

class Di {
  final Clock clock;

  final Fs fs;

  final DiligenceConfig config;

  final bool isTest;

  Di({
    required this.config,
    Clock? clock,
    Fs? fs,
    this.isTest = false,
  })  : clock = clock ?? Clock(),
        fs = fs ?? Fs();

  String get dbPath => config.dbPath;

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
          case ReminderJob _:
            return reminderJobRunner;
          default:
            throw ArgumentError('Unknown job type: ${inputJob.runtimeType}');
        }
      };

  ReminderJobRunner get reminderJobRunner => _cache.getSet(
        #reminderJobRunner,
        () => ReminderJobRunner(
          noticeQueue: noticeQueue,
          diligent: diligent,
          clock: clock,
        ),
      );

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

  NoticeQueue get noticeQueue => _cache.getSet(
        #noticeQueue,
        () => NoticeQueue(
          isTest: isTest,
          db: db,
          clock: clock,
          noticeFactoryFunc: noticeFactoryFunc,
        ),
      );

  NoticeFactoryFunc<Notice> get noticeFactoryFunc => (data) {
        switch (data.type) {
          case 'generic':
            return genericNoticeFactoryFunc(data);
          case 'reminder':
            return reminderNoticeFactoryFunc(data);
          case 'error':
            return errorNoticeFactoryFunc(data);
          default:
            throw Exception('Unknown notice type: $data.type');
        }
      };

  NoticeFactoryFunc<ReminderNotice> get reminderNoticeFactoryFunc =>
      (row) async {
        final taskId = row.taskId!;
        return ReminderNotice(
          uuid: row.uuid,
          createdAt: row.createdAt,
          task: (await diligent.findTask(taskId))!,
          diligent: diligent,
        );
      };

  NoticeFactoryFunc<ErrorNotice> get errorNoticeFactoryFunc => (row) async {
        return ErrorNotice(
          uuid: row.uuid,
          createdAt: row.createdAt,
          title: row.title as String,
          details: row.details,
        );
      };
}
