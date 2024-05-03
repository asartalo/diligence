import '../../models/scheduled_job.dart';

sealed class JobRunResult {
  const JobRunResult(this.message);
  final String message;
}

class JobRunSuccess extends JobRunResult {
  const JobRunSuccess(super.message);
}

class JobRunFailure extends JobRunResult {
  const JobRunFailure(super.message);
}

abstract class JobRunner<J extends ScheduledJob> {
  Future<JobRunResult> runJob(J job);
}
