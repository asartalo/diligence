import 'package:sqlite_async/sqlite_async.dart';

import '../../../models/tasks.dart';
import 'task_event.dart';

class AddedTasksEvent extends TaskEvent {
  final TaskList tasks;
  final int? parentId;
  final SqliteWriteContext tx;

  AddedTasksEvent(
    super.at, {
    this.parentId,
    required this.tasks,
    required this.tx,
  });
}
