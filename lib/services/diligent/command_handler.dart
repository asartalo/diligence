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
