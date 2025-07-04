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

import 'package:file/file.dart';
import 'package:sqlite_async/sqlite_async.dart';

import '../diligence_config.dart';
import '../models/notices/error_notice.dart';
import '../models/notices/notice.dart';
import '../models/notices/reminder_notice.dart';
import '../models/reminder_job.dart';
import '../models/scheduled_job.dart';
import '../platform_wrapped.dart';
import '../services/config_manager.dart';
import '../services/diligent/diligent.dart';
import '../services/diligent/focus_queue_manager.dart';
import '../services/diligent/reminders/reminders.dart';
import '../services/diligent/sqlite_backend_common.dart';
import '../services/diligent/tasks/tasks_db_reader.dart';
import '../services/diligent/sqlite_backend.dart';
import '../services/jobs/job_queue.dart';
import '../services/jobs/job_track.dart';
import '../services/jobs/reminder_job_runner.dart';
import '../services/logger/logger_factory.dart';
import '../services/logger/observer_logger.dart';
import '../services/notices/notice_queue.dart';
import '../utils/clock.dart';
import '../services/logger/logger.dart';
import 'read_tx_scope.dart';
import 'root_scope.dart';
import 'write_tx_scope.dart';

typedef LogerFactoryFunc = Logger Function(String name);

class AppStateScope {
  final RootScope parent;

  final DiligenceConfig config;

  Clock get clock => parent.clock;

  FileSystem get fileSystem => parent.fileSystem;

  PlatformWrapped get platform => parent.platform;

  bool get isTest => parent.isTest;

  ConfigManager get configManager => parent.configManager;

  AppStateScope({required this.parent, required this.config}) {
    actualConfigManagerLogger;
  }

  void stop() {
    actualConfigManagerLogger.stop();
  }

  String get dbPath => config.dbPath;

  Diligent? _diligent;
  Diligent get diligent =>
      _diligent ??= Diligent(isTest: isTest, clock: clock, backend: backend);

  TasksDbReader? _tasksReader;
  TasksDbReader get tasksReader => _tasksReader ??= TasksDbReader(tx: db);

  RemindersDbReader? _remindersRepository;
  RemindersDbReader get remindersRepository =>
      _remindersRepository ??= RemindersDbReader(clock: clock, tx: db);

  FocusQueueManager? _focusQueueManager;
  FocusQueueManager get focusQueueManager =>
      _focusQueueManager ??= FocusQueueManager(clock: clock, db: db);

  SqliteDatabase? _db;
  SqliteDatabase get db => _db ??= SqliteDatabase(path: dbPath);

  LoggerFactory? _loggerFactory;
  LoggerFactory get loggerFactory => _loggerFactory ??= LoggerFactory.create(
    clock,
    logFile: config.logToFile ? config.logFilePath : '',
  );

  LogerFactoryFunc get loggerFactoryFunc => (name) {
    return loggerFactory.createBasicLogger(name);
  };

  ObserverLogger? _actualConfigManagerLogger;
  ObserverLogger get actualConfigManagerLogger => _actualConfigManagerLogger ??=
      loggerFactory.createObserverLogger(parent.configManagerLogger);

  RunnerFactoryFunc get runnerFactoryFunc => (ScheduledJob inputJob) {
    switch (inputJob) {
      case ReminderJob _:
        return reminderJobRunner;
      default:
        throw ArgumentError('Unknown job type: ${inputJob.runtimeType}');
    }
  };

  ReminderJobRunner? _reminderJobRunner;
  ReminderJobRunner get reminderJobRunner =>
      _reminderJobRunner ??= ReminderJobRunner(
        noticeQueue: noticeQueue,
        diligent: diligent,
        clock: clock,
      );

  Logger? _jobQueueLogger;
  Logger get jobQueueLogger => _jobQueueLogger ??= (isTest
      ? loggerFactoryFunc('JobQueue for Tests')
      : loggerFactoryFunc('JobQueue'));

  JobQueue? _jobQueue;
  JobQueue get jobQueue => _jobQueue ??= JobQueue.forTests(
    db: db,
    logger: jobQueueLogger,
    clock: clock,
  );

  JobTrack? _jobTrack;
  JobTrack get jobTrack => _jobTrack ??= JobTrack(
    clock: clock,
    runnerFactoryFunc: runnerFactoryFunc,
    jobQueue: jobQueue,
    logger: loggerFactoryFunc('JobTrack'),
  );

  NoticeQueue? _noticeQueue;
  NoticeQueue get noticeQueue => _noticeQueue ??= NoticeQueue(
    isTest: isTest,
    db: db,
    clock: clock,
    noticeFactoryFunc: noticeFactoryFunc,
  );

  SqliteBackend? _backend;
  SqliteBackend get backend => _backend ??= SqliteBackend(
    db: db,
    writeTxFn: writeTxScopeFn,
    readTxFn: readTxScopeFn,
    tasksReader: tasksReader,
    focusQueueManager: focusQueueManager,
    remindersReader: remindersRepository,
    clock: clock,
  );

  WriteTxScopeFn get writeTxScopeFn => (SqliteWriteContext tx) {
    return WriteTxScope(parent: this, tx: tx);
  };

  ReadTxScopeFn get readTxScopeFn => (SqliteReadContext tx) {
    return ReadTxScope(parent: this, tx: tx, clock: clock);
  };

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

typedef TransactFunc<T> = Future<T> Function(WriteTxScope scope);
