import '../tasks/tasks.dart';
import 'task_event.dart';

class DeletedTaskEvent extends TaskEvent {
  final Task task;

  DeletedTaskEvent(super.at, {required this.task});
}
