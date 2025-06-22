import 'package:file/file.dart';
import 'package:sqlite_async/sqlite_async.dart';

import '../di_scope_cache.dart';
import '../diligence_config.dart';
import '../models/notices/error_notice.dart';
import '../models/notices/notice.dart';
import '../models/notices/reminder_notice.dart';
import '../models/reminder_job.dart';
import '../models/scheduled_job.dart';
import '../platform_wrapped.dart';
import '../services/config_manager.dart';
import '../services/diligent.dart';
import '../services/jobs/job_queue.dart';
import '../services/jobs/job_track.dart';
import '../services/jobs/reminder_job_runner.dart';
import '../services/logger/logger_factory.dart';
import '../services/logger/observer_logger.dart';
import '../services/notices/notice_queue.dart';
import '../utils/clock.dart';
import '../services/logger/logger.dart';
import 'root_scope.dart';

typedef LogerFactoryFunc = Logger Function(String name);

class AppStateScope {
  final RootScope parent;

  final DiligenceConfig config;

  final DiScopeCache _cache;

  Clock get clock => parent.clock;

  FileSystem get fileSystem => parent.fileSystem;

  PlatformWrapped get platform => parent.platform;

  bool get isTest => parent.isTest;

  ConfigManager get configManager => parent.configManager;

  AppStateScope({required this.parent, required this.config})
    : _cache = DiScopeCache() {
    actualConfigManagerLogger;
  }

  void stop() {
    actualConfigManagerLogger.stop();
  }

  String get dbPath => config.dbPath;

  Diligent get diligent => _cache.getSet(
    #diligent,
    () => Diligent.convenience(isTest: isTest, db: db, clock: clock),
  );

  SqliteDatabase get db =>
      _cache.getSet(#db, () => SqliteDatabase(path: dbPath));

  LoggerFactory get loggerFactory => _cache.getSet(
    #loggerFactory,
    () => LoggerFactory.create(
      clock,
      logFile: config.logToFile ? config.logFilePath : '',
    ),
  );

  LogerFactoryFunc get loggerFactoryFunc => (name) {
    return loggerFactory.createBasicLogger(name);
  };

  ObserverLogger get actualConfigManagerLogger => _cache.getSet(
    #acml,
    () => loggerFactory.createObserverLogger(parent.configManagerLogger),
  );

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
        ? JobQueue.forTests(
            db: db,
            logger: loggerFactoryFunc('JobQueue for Tests'),
            clock: clock,
          )
        : JobQueue(db: db, logger: loggerFactoryFunc('JobQueue'), clock: clock),
  );

  JobTrack get jobTrack => _cache.getSet(
    #jobTrack,
    () => JobTrack(
      clock: clock,
      runnerFactoryFunc: runnerFactoryFunc,
      jobQueue: jobQueue,
      logger: loggerFactoryFunc('JobTrack'),
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
