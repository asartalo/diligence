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

import 'package:sqlite_async/sqlite_async.dart';

import '../focus_queue_manager.dart';
import '../tasks/modified_task.dart';
import '../../../utils/clock.dart';
import '../tasks/tasks_db_writer.dart';

abstract class TasksTransaction {
  final SqliteWriteContext tx;

  final Clock clock;

  final TasksDbWriter tasksDbWriter;

  final FocusQueueManager focusQueueManager;

  TasksTransaction(
    this.tx, {
    required this.clock,
    required this.tasksDbWriter,
    required this.focusQueueManager,
  });

  Future<void> broadcastChanges(
    TasksDbWriterResult result, {
    ModifiedTask? updatedTaskOriginal,
  }) async {
    await _announceNewTasks(result);
    if (updatedTaskOriginal is ModifiedTask) {
      await _announceUpdatedTasks(result, updatedTaskOriginal);
    }
    await _announceToggledTasks(result);
    await _announceDeletedTask(result);
  }

  Future<void> _announceNewTasks(TasksDbWriterResult result) async {
    final newTasks = result.addedTasks;

    if (newTasks.isEmpty) {
      return;
    }

    final parentId = newTasks.first.parentId;
    if (parentId is int) {
      await focusQueueManager.shiftFocusToChildren(parentId, newTasks, tx);
    }
  }

  Future<void> _announceUpdatedTasks(
    TasksDbWriterResult result,
    ModifiedTask updatedTaskBefore,
  ) async {
    await focusQueueManager.manageModifiedTask(updatedTaskBefore, tx);
  }

  Future<void> _announceToggledTasks(TasksDbWriterResult result) async {
    for (final MapEntry(key: doneAt, value: tasks)
        in result.toggledTasksGroupedByDoneAt().entries) {
      if (doneAt is DateTime) {
        await focusQueueManager.unfocusInContext(tasks, tx);
      }
    }
  }

  Future<void> _announceDeletedTask(TasksDbWriterResult result) async {
    if (result.deletedTasks.isEmpty) {
      return;
    }

    await focusQueueManager.handleDeletedTasks(result.deletedTasks);
  }
}
