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

import '../../../models/commands/commands.dart';

import '../../diligent.dart';
import 'fails_on_exception.dart';

Future<CommandResult> updateTaskHandler(
  Diligent diligent,
  UpdateTaskCommand command,
) async {
  return failsOnException(
    () async {
      final persisted = await diligent.updateTask(command.payload);

      return SuccessPack(
        message: 'Task "${command.payload.name}" was updated successfully.',
        payload: persisted,
      );
    },
    'Failed to update task "${command.payload.name}".',
  );
}
