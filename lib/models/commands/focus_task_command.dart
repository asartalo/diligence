import 'package:flutter/foundation.dart' show immutable;
import '../task.dart';
import 'command.dart';

@immutable
class FocusTaskCommand extends CommandPack<Task> {
  final Task task;

  FocusTaskCommand({
    super.message = 'Task focused',
    required this.task,
  });

  @override
  Task get payload => task;
}
