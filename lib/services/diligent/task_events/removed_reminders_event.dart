import '../../../models/reminders/reminder.dart';
import 'task_event.dart';

class RemovedRemindersEvent extends TaskEvent {
  final List<Reminder> reminders;

  RemovedRemindersEvent(
    super.at, {
    required this.reminders,
  });
}
