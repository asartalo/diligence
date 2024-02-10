import '../modified_task.dart';
import 'base_command.dart';

class UpdateTaskCommand extends CommandWithPayload<ModifiedTask> {
  UpdateTaskCommand({
    super.message = 'Task updated',
    required super.payload,
  });
}
