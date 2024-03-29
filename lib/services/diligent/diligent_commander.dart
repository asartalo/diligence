// Diligence - A Task Management App
//
// Copyright (C) 2024 Wayne Duran <asartalo@gmail.com>
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// this program. If not, see <https://www.gnu.org/licenses/>.

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
