import 'dart:async';

import '../../models/scheduled_job.dart';
import '../../utils/clock.dart';
import '../../utils/logger.dart';
import 'job_queue.dart';
import 'job_runner.dart';

typedef RunnerFactoryFunc = JobRunner Function(ScheduledJob job);
typedef JobFunc = void Function();

/// JobTrack is where JobRunners run.
class JobTrack implements NextJobListener {
  ScheduledJob? nextJob;
  Timer? _queuedTimer;
  Timer? _pulseTimer;
  DateTime? _nextJobIn;
  JobFunc? _jobFunc;
  bool isIdle = true;
  final Clock clock;
  final RunnerFactoryFunc runnerFactoryFunc;
  final JobQueue jobQueue;
  final Logger logger;

  JobTrack({
    required this.clock,
    required this.runnerFactoryFunc,
    required this.jobQueue,
    required this.logger,
  });

  Future<ScheduledJob?> start() async {
    if (isIdle) {
      jobQueue.registerNextJobListener(this);
      isIdle = false;
    }
    _pulseTimer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = clock.now();
      final currentTimer = _queuedTimer;
      final nextJobIn = _nextJobIn;
      final jobFunc = _jobFunc;
      if (currentTimer is Timer &&
          nextJobIn is DateTime &&
          jobFunc is JobFunc) {
        if (now.isAfter(nextJobIn)) {
          logger.trace('Manually running past job');
          jobFunc();
        }
      }
    });
    return await next();
  }

  Future<void> stop() async {
    if (!isIdle) {
      if (_queuedTimer is Timer) {
        _queuedTimer!.cancel();
      }
      _pulseTimer?.cancel();
      _jobFunc = null;
      isIdle = true;
    }
  }

  Future<ScheduledJob?> next() async {
    final job = await jobQueue.nextJob();
    _setNextJob(job);
    return job;
  }

  void _setNextJob(ScheduledJob? job) {
    if (job == null) {
      _nextJobIn = null;
      return;
    }

    if (_queuedTimer is Timer) {
      _queuedTimer!.cancel();
    }

    final doItIn = _doItIn(job.runAt);
    _nextJobIn = job.runAt;
    logger.debug('Scheduling job ($job) to run in $doItIn');
    jobFunc() async {
      if (await jobQueue.isPending(job)) {
        final runner = runnerFactoryFunc(job);
        logger.info('Running job -> $job');
        // TODO: How to handle job run failures?
        await runner.runJob(job);
        await jobQueue.completeJob(job);
      }
      _jobFunc = null;
      next();
    }

    _jobFunc = jobFunc;
    _queuedTimer = clock.timer(doItIn, jobFunc);
  }

  Duration _doItIn(DateTime runAt) {
    final now = clock.now();

    if (now.isAfter(runAt)) {
      return Duration.zero;
    }
    return runAt.difference(now);
  }

  @override
  Future<void> handleNextJobUpdate(ScheduledJob job) async {
    _setNextJob(job);
  }
}
