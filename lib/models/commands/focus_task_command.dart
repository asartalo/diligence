import 'package:flutter/foundation.dart' show immutable;
import '../task.dart';
import 'command.dart';

@immutable
class FocusTaskCommand extends CommandPack<Task> {
  FocusTaskCommand({
    super.message = 'Task focused',
    required super.payload,
  });
}
