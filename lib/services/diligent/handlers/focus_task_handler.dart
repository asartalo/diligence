import '../../../models/commands/commands.dart';

import '../../diligent.dart';
import 'fails_on_exception.dart';

Future<CommandResult> focusTaskHandler(
  Diligent diligent,
  FocusTaskCommand command,
) async {
  return failsOnException(
    () async {
      await diligent.focus(command.payload);
      return Success(
        message: 'Task "${command.payload.name}" was focused successfully.',
      );
    },
    'Failed to focus task "${command.payload.name}".',
  );
}
