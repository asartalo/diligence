import '../../../models/commands/commands.dart';
import '../../diligent.dart';
import 'fails_on_exception.dart';

Future<CommandResult> deleteTaskHandler(
  Diligent diligent,
  DeleteTaskCommand command,
) async {
  return failsOnException(
    () async {
      await diligent.deleteTask(command.payload);
      return Success(
        message: 'Task "${command.payload.name}" was deleted successfully.',
      );
    },
    'Failed to delete task "${command.payload.name}".',
  );
}
