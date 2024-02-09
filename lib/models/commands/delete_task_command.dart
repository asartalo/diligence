import '../persisted_task.dart';
import 'base_command.dart';

class DeleteTaskCommand extends CommandWithPayload<PersistedTask> {
  DeleteTaskCommand({
    super.message = 'Task deleted',
    required super.payload,
  });
}
