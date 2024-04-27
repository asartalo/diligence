import 'scheduled_job.dart';

class ReminderJob extends ScheduledJob {
  final int taskId;

  ReminderJob({
    super.uuid,
    required super.runAt,
    required this.taskId,
  }) : super(type: 'reminder');

  @override
  List<Object?> get props => [uuid, runAt, type, taskId];
}
