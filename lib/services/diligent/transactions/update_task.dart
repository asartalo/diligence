// Diligence - A Task Management App
//
// Copyright (C) 2025 Wayne Duran <asartalo@gmail.com>
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

import '../../../models/modified_task.dart';
import '../../../models/task.dart';
import 'transactions.dart';

class UpdateTask extends EventAnnouncer {
  UpdateTask(
    super.tx, {
    required super.eventRegistry,
    required super.clock,
    required super.tasksRepository,
  });

  Future<Task> work(Task task) async {
    if (task is! ModifiedTask) {
      throw ArgumentError('Task must be a ModifiedTask');
    }

    final result = await tasksRepository.updateTask(task);
    final updatedTask = result.updatedTasks.first;
    await broadcastChanges(result, updatedTaskOriginal: task);

    return updatedTask;
  }
}
