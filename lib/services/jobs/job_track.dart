import 'dart:async';

import 'package:clock/clock.dart';

import '../../models/scheduled_job.dart';
import 'job_queue.dart';
import 'job_runner.dart';

typedef RunnerFactoryFunc = JobRunner Function(ScheduledJob job);

class JobTrack implements NextJobListener {
  ScheduledJob? nextJob;
  Timer? _queuedTimer;
  bool isIdle = true;
  final Clock clock;
  final RunnerFactoryFunc runnerFactoryFunc;
  final JobQueue jobQueue;

  JobTrack({
    required this.clock,
    required this.runnerFactoryFunc,
    required this.jobQueue,
  });

  Future<ScheduledJob?> start() async {
    if (isIdle) {
      jobQueue.registerNextJobListener(this);
      isIdle = false;
    }
    return await next();
  }

  Future<ScheduledJob?> next() async {
    final job = await jobQueue.nextJob();
    _setNextJob(job);
    return job;
  }

  void _setNextJob(ScheduledJob? job) {
    if (job == null) return;

    if (_queuedTimer is Timer) {
      _queuedTimer!.cancel();
    }

    _queuedTimer = Timer(_doItIn(job.runAt), () async {
      if (await jobQueue.isPending(job)) {
        final runner = runnerFactoryFunc(job);
        // TODO: How to handle job run failures?
        await runner.runJob(job);
        await jobQueue.completeJob(job);
      }
      next();
    });
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
