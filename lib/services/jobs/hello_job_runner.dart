import '../../models/scheduled_job.dart';
import 'job_runner.dart';

class HelloJob extends ScheduledJob {
  HelloJob({required super.runAt}) : super(type: 'hello');
}

class HelloJobRunner extends JobRunner<HelloJob> {
  @override
  Future<JobRunResult> runJob(HelloJob job) async {
    // ignore: avoid_print
    print('Hello, world!');
    return const JobRunSuccess('Hello, world!');
  }
}
