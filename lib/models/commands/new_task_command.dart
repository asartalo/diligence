import 'package:flutter/foundation.dart' show immutable;

import '../new_task.dart';
import 'command.dart';

@immutable
class NewTaskCommand extends CommandPack<NewTask> {
  NewTaskCommand({
    super.message = 'New task created',
    required super.payload,
  });
}
