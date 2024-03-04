import '../../../models/commands/commands.dart';

import '../../diligent.dart';
import 'fails_on_exception.dart';

Future<CommandResult> updateTaskHandler(
  Diligent diligent,
  UpdateTaskCommand command,
) async {
  return failsOnException(
    () async {
      final persisted = await diligent.updateTask(command.payload);

      return SuccessPack(
        message: 'Task "${command.payload.name}" was updated successfully.',
        payload: persisted,
      );
    },
    'Failed to update task "${command.payload.name}".',
  );
}
