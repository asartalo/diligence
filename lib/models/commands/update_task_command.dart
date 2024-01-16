import '../provided_task.dart';
import 'base_command.dart';

class UpdateTaskCommand extends CommandWithPayload<ProvidedTask> {
  UpdateTaskCommand({
    super.message = 'Task updated',
    required super.payload,
  });
}
