import 'package:meta/meta.dart';

import 'reminders/reminder_list.dart';
import 'tasks.dart';

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
