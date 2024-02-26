abstract class CommandResult {
  bool get success;
  final String? message;

  CommandResult({this.message});
}

class Success extends CommandResult {
  @override
  final bool success = true;

  Success({super.message});
}

class Fail extends CommandResult {
  @override
  final bool success = false;

  Fail({super.message});
}

class SuccessPack<T> extends Success {
  final T payload;

  SuccessPack({required this.payload, super.message});
}

class FailPack<T> extends Fail {
  final T payload;

  FailPack({required this.payload, super.message});
}
