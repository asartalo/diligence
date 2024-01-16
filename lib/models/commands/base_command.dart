abstract class Command {
  String? message;

  Command({this.message});
}

abstract class CommandWithPayload<T> extends Command {
  final T payload;

  CommandWithPayload({super.message, required this.payload});
}

class NoOpCommand extends Command {
  NoOpCommand();
}

final noOpCommand = NoOpCommand();
