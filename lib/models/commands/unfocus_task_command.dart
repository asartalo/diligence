import 'package:flutter/foundation.dart' show immutable;
import '../task.dart';
import 'command.dart';

@immutable
class UnfocusTaskCommand extends CommandPack<Task> {
  final Task task;

  UnfocusTaskCommand({
    super.message = 'Unfocused task',
    required this.task,
  });

  @override
  Task get payload => task;
}
