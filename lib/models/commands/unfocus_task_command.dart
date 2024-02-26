import 'package:flutter/foundation.dart' show immutable;
import '../task.dart';
import 'command.dart';

@immutable
class UnfocusTaskCommand extends CommandPack<Task> {
  UnfocusTaskCommand({
    super.message = 'Unfocused task',
    required super.payload,
  });
}
