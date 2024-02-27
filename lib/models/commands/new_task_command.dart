import 'package:flutter/foundation.dart' show immutable;

import '../new_task.dart';
import 'command.dart';

@immutable
class NewTaskCommand extends CommandPack<NewTask> {
  final NewTask task;

  NewTaskCommand({
    super.message = 'New task created',
    required this.task,
  });

  @override
  NewTask get payload => task;
}
