import '../../../models/reminders/reminder.dart';
import 'task_event.dart';

class AddedRemindersEvent extends TaskEvent {
  final List<Reminder> reminders;

  AddedRemindersEvent(
    super.at, {
    required this.reminders,
  });
}
