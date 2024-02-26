import '../../../models/commands/commands.dart';

import '../../diligent.dart';
import 'fails_on_exception.dart';

Future<CommandResult> unfocusTaskHandler(
  Diligent diligent,
  UnfocusTaskCommand command,
) async {
  return failsOnException(
    () async {
      await diligent.unfocus(command.payload);
      return Success(
        message: 'Task "${command.payload.name}" was unfocused successfully.',
      );
    },
    'Failed to unfocus task "${command.payload.name}".',
  );
}
