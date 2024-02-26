import '../../models/commands/commands.dart';
import '../diligent.dart';

typedef BaseCommandHandler = Future<CommandResult> Function(
  Diligent diligent,
  Command command,
);

typedef CommandHandler<T extends Command> = Future<CommandResult> Function(
  Diligent diligent,
  T command,
);

BaseCommandHandler wrapHandler<T extends Command>(
  CommandHandler<T> handler,
) {
  return (Diligent diligent, Command command) {
    if (command is T) {
      return handler(diligent, command);
    }

    // Expecting this never happens
    return Future.value(
      Fail(message: 'Expected instance of $T but got: ${command.runtimeType}'),
    );
  };
}
