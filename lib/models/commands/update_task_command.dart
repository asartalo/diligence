import 'package:flutter/foundation.dart' show immutable;

import '../modified_task.dart';
import 'command.dart';

@immutable
class UpdateTaskCommand extends CommandPack<ModifiedTask> {
  final ModifiedTask task;

  UpdateTaskCommand({
    super.message = 'Task updated',
    required this.task,
  });

  @override
  ModifiedTask get payload => task;
}
