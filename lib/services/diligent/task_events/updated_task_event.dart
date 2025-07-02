import 'package:sqlite_async/sqlite_async.dart';

import '../tasks/tasks.dart';
import 'task_event.dart';

class UpdatedTaskEvent extends TaskEvent {
  final ModifiedTask modified;
  final PersistedTask persisted;
  final SqliteWriteContext tx;

  UpdatedTaskEvent(
    super.at, {
    required this.modified,
    required this.persisted,
    required this.tx,
  });
}
