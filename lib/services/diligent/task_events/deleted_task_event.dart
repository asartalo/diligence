import 'package:sqlite_async/sqlite_async.dart';

import '../../../models/tasks.dart';
import 'task_event.dart';

class DeletedTaskEvent extends TaskEvent {
  final Task task;
  final SqliteWriteContext tx;

  DeletedTaskEvent(
    super.at, {
    required this.task,
    required this.tx,
  });
}
