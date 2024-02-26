import '../../../models/commands/commands.dart';

typedef HandlerCallback = Future<CommandResult> Function();

Future<CommandResult> failsOnException(
  HandlerCallback callback,
  String failMessage,
) async {
  try {
    return await callback();
  } catch (e) {
    return FailPack(
      payload: e,
      message: failMessage,
    );
  }
}
