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

import '../../../models/modified_task.dart';
import '../../../models/persisted_task.dart';
import '../../../utils/clock.dart';
import '../task_events/added_tasks_event.dart';
import '../task_events/task_event.dart';
import '../task_events/task_event_registry.dart';
import '../task_events/toggled_tasks_done_event.dart';
import '../task_events/updated_task_event.dart';
import '../tasks_repository.dart';

abstract class EventAnnouncer {
  final SqliteWriteContext tx;

  final Clock clock;

  final TaskEventRegistry eventRegistry;

  final TasksRepository tasksRepository;

  EventAnnouncer(
    this.tx, {
    required this.clock,
    required this.eventRegistry,
    required this.tasksRepository,
  });

  Future<void> broadcastChanges(
    TasksRepositoryResult result, {
    ModifiedTask? updatedTaskOriginal,
  }) async {
    await _announceNewTasks(result);
    if (updatedTaskOriginal is ModifiedTask) {
      await _announceUpdatedTasks(result, updatedTaskOriginal);
    }
    await _announceToggledTasksEvents(result);
  }

  Future<void> _announceNewTasks(TasksRepositoryResult result) async {
    final newTasks = result.addedTasks;

    if (newTasks.isEmpty) {
      return;
    }

    final parentId = newTasks.first.parentId;

    await announceEvent(
      AddedTasksEvent(clock.now(), tx: tx, parentId: parentId, tasks: newTasks),
    );
  }

  Future<void> _announceUpdatedTasks(
    TasksRepositoryResult result,
    ModifiedTask updatedTaskBefore,
  ) async {
    final updatedTask = result.updatedTasks.first;

    await eventRegistry.broadcast(
      UpdatedTaskEvent(
        clock.now(),
        modified: updatedTaskBefore,
        persisted: updatedTask as PersistedTask,
        tx: tx,
      ),
    );
  }

  Future<void> _announceToggledTasksEvents(TasksRepositoryResult result) async {
    for (final entry in result.toggledTasksGroupedByDoneAt().entries) {
      announceEvent(
        ToggledTasksDoneEvent(
          clock.now(),
          tasks: entry.value,
          tx: tx,
          doneAt: entry.key,
        ),
      );
    }
  }

  Future<void> announceEvent<T extends TaskEvent>(T event) =>
      eventRegistry.broadcast<T>(event);
}
