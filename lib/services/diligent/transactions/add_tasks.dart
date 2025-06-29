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

import 'package:clock/clock.dart';
import 'package:sqlite_async/sqlite_async.dart';

import '../../../models/task_list.dart';
import '../task_events/added_tasks_event.dart';
import '../task_events/task_event.dart';
import '../task_events/task_event_registry.dart';
import '../task_events/toggled_tasks_done_event.dart';
import '../tasks_repository.dart';

class AddTasks {
  final SqliteWriteContext _tx;

  final TaskEventRegistry _eventRegistry;

  final TasksRepository _tasksRepository;

  AddTasks(
    this._tx, {
    required TaskEventRegistry eventRegistry,
    required TasksRepository tasksRepository,
  }) : _eventRegistry = eventRegistry,
       _tasksRepository = tasksRepository;

  Future<TaskList> work(TaskList tasks, {int? position}) async {
    final parentId = tasks.first.parentId;
    final result = await _tasksRepository.addTask(tasks, position: position);

    final newTasks = result.addedTasks;

    await announceEvent(
      AddedTasksEvent(
        clock.now(),
        tx: _tx,
        parentId: parentId,
        tasks: newTasks,
      ),
    );

    for (final entry in result.toggledTasksGroupedByDoneAt().entries) {
      announceEvent(
        ToggledTasksDoneEvent(
          clock.now(),
          tasks: entry.value,
          tx: _tx,
          doneAt: entry.key,
        ),
      );
    }

    return newTasks;
  }

  Future<void> announceEvent<T extends TaskEvent>(T event) async {
    await _eventRegistry.broadcast<T>(event);
  }
}
