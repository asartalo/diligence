import '../../models/notices/reminder_notice.dart';
import '../../models/reminder_job.dart';
import '../../utils/clock.dart';
import '../diligent.dart';
import '../notices/notice_queue.dart';
import 'job_runner.dart';

class ReminderJobRunner extends JobRunner<ReminderJob> {
  final NoticeQueue noticeQueue;
  final Diligent diligent;
  final Clock clock;

  ReminderJobRunner({
    required this.noticeQueue,
    required this.diligent,
    required this.clock,
  });

  @override
  Future<JobRunResult> runJob(ReminderJob job) async {
    final task = await diligent.findTask(job.taskId);
    if (task == null) {
      return JobRunFailure(
        'Task with task id ${job.taskId} was not found',
      );
    }
    if (task.done) {
      return JobRunSuccess('Task #${job.taskId} is already done.');
    }
    await noticeQueue.addNotice(ReminderNotice(
      task: task,
      diligent: diligent,
      createdAt: clock.now(),
    ));

    return const JobRunSuccess('ReminderNotice added');
  }
}
