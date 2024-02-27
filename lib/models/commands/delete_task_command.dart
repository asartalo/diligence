import 'package:flutter/foundation.dart' show immutable;

import '../persisted_task.dart';
import 'command.dart';

@immutable
class DeleteTaskCommand extends CommandPack<PersistedTask> {
  final PersistedTask task;

  DeleteTaskCommand({
    super.message = 'Task deleted',
    required this.task,
  });

  @override
  PersistedTask get payload => task;
}
