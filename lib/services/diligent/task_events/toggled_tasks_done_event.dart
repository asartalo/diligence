import 'package:sqlite_async/sqlite_async.dart';

import '../../../models/task_list.dart';
import 'task_event.dart';

class ToggledTasksDoneEvent extends TaskEvent {
  final TaskList tasks;
  final SqliteWriteContext tx;
  final DateTime? doneAt;

  ToggledTasksDoneEvent(
    super.at, {
    required this.tasks,
    required this.tx,
    this.doneAt,
  });
}
