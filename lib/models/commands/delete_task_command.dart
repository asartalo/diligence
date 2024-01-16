import '../provided_task.dart';
import 'base_command.dart';

class DeleteTaskCommand extends CommandWithPayload<ProvidedTask> {
  DeleteTaskCommand({
    super.message = 'Task deleted',
    required super.payload,
  });
}
