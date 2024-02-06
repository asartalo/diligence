import '../task.dart';
import 'base_command.dart';

class FocusTaskCommand extends CommandWithPayload<Task> {
  FocusTaskCommand({
    super.message = 'Task focused',
    required super.payload,
  });
}
