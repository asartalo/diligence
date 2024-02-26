import '../../models/commands/commands.dart';
import '../diligent.dart';
import 'command_handlers.dart';
import 'handlers/delete_task_handler.dart';
import 'handlers/focus_task_handler.dart';
import 'handlers/new_task_handler.dart';
import 'handlers/unfocus_task_hander.dart';
import 'handlers/update_task_handler.dart';

CommandHandlers mainHandlers() {
  final handlers = CommandHandlers();
  handlers.add(newTaskHandler);
  handlers.add(deleteTaskHandler);
  handlers.add(updateTaskHandler);
  handlers.add(focusTaskHandler);
  handlers.add(unfocusTaskHandler);

  return handlers;
}

class DiligentCommander {
  final Diligent diligent;
  final CommandHandlers handlers = mainHandlers();

  DiligentCommander(this.diligent);

  Future<CommandResult> handle(Command command) async {
    final handler = handlers[command.runtimeType];
    if (handler != null) {
      return await handler(diligent, command);
    }
    return Fail(message: 'Unknown command: ${command.runtimeType}');
  }
}
