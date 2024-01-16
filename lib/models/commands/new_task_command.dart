import '../new_task.dart';
import 'base_command.dart';

class NewTaskCommand extends CommandWithPayload<NewTask> {
  NewTaskCommand({
    super.message = 'New task created',
    required super.payload,
  });
}
