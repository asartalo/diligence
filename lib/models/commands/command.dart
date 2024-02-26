import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class Command {
  final String? message;
  final DateTime at;

  Command({this.message}) : at = DateTime.now();
}

@immutable
abstract class CommandPack<T> extends Command {
  final T payload;

  CommandPack({super.message, required this.payload});
}

@immutable
class NoOpCommand extends Command {
  NoOpCommand();
}

final noOpCommand = NoOpCommand();
