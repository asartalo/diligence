import '../../../models/commands/commands.dart';

import '../../diligent.dart';
import 'fails_on_exception.dart';

Future<CommandResult> newTaskHandler(
  Diligent diligent,
  NewTaskCommand command,
) async {
  return failsOnException(
    () async {
      final persisted = await diligent.addTask(command.payload);
      return SuccessPack(
        message: 'Task "${command.payload.name}" added successfully.',
        payload: persisted,
      );
    },
    'Failed to add task "${command.payload.name}".',
  );
}
