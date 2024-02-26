import 'package:flutter/foundation.dart' show immutable;

import '../modified_task.dart';
import 'command.dart';

@immutable
class UpdateTaskCommand extends CommandPack<ModifiedTask> {
  UpdateTaskCommand({
    super.message = 'Task updated',
    required super.payload,
  });
}
