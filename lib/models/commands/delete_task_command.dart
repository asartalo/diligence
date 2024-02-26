import 'package:flutter/foundation.dart' show immutable;

import '../persisted_task.dart';
import 'command.dart';

@immutable
class DeleteTaskCommand extends CommandPack<PersistedTask> {
  DeleteTaskCommand({
    super.message = 'Task deleted',
    required super.payload,
  });
}
