import '../../models/commands/commands.dart';
import 'command_handler.dart';

export 'command_handler.dart';

class CommandHandlers {
  final Map<Type, BaseCommandHandler> _handlers = {};

  CommandHandlers();

  BaseCommandHandler? operator [](Type type) => _handlers[type];

  void add<T extends Command>(
    CommandHandler<T> handler,
  ) {
    _handlers[T] = wrapHandler(handler);
  }
}
