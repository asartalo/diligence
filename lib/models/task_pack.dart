import 'package:meta/meta.dart';

import '../services/diligent/reminders/reminders.dart';
import '../services/diligent/tasks/tasks.dart';

@immutable
class TaskPack {
  final Task task;
  final ReminderList reminders;

  bool get isModified => task is ModifiedTask || reminders.isModified;

  bool get isNew => task is NewTask;

  const TaskPack(this.task, {required this.reminders});

  TaskPack updateTask(Task task) {
    return TaskPack(task, reminders: reminders);
  }
}
