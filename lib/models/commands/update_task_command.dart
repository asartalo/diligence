import '../persisted_task.dart';
import 'base_command.dart';

class UpdateTaskCommand extends CommandWithPayload<PersistedTask> {
  UpdateTaskCommand({
    super.message = 'Task updated',
    required super.payload,
  });
}
