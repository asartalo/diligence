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

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:sqlite_async/sqlite_async.dart';

import '../../models/task.dart';
import '../../models/task_list.dart';
import '../../utils/clock.dart';
import '../../utils/debounce.dart';
import '../diligent.dart';
import 'diligent_event_register.dart';
import 'task_db.dart';
import 'task_events/added_tasks_event.dart';
import 'task_events/deleted_task_event.dart';
import 'task_events/toggled_tasks_done_event.dart';
import 'task_events/updated_task_event.dart';
import 'task_fields.dart';

class FocusQueueEvent {
  final DateTime at;

  FocusQueueEvent(this.at);
}

class FocusQueueManager extends TaskDb implements DiligentEventRegister {
  @override
  final SqliteDatabase db;
  final _controller = StreamController<FocusQueueEvent>();
  Stream<FocusQueueEvent>? _updateEventStream;
  late VoidCallback _broadcastUpdate;

  final Clock clock;

  FocusQueueManager({required this.db, required this.clock}) {
    // We use debounce to prevent broadcasting too quickly
    _broadcastUpdate =
        debounce(() => _controller.sink.add(FocusQueueEvent(clock.now())));
  }

  Stream<FocusQueueEvent> get updateEventStream {
    if (_updateEventStream != null) {
      return _updateEventStream as Stream<FocusQueueEvent>;
    } else {
      final theStream = _controller.stream.asBroadcastStream();
      _updateEventStream = theStream;
      return theStream;
    }
  }

  Future<TaskList> focusQueue({int? limit}) async {
    final rows = await db.getAll(
      '''
      SELECT tasks.*, focusQueue.position
      FROM tasks
      JOIN focusQueue ON focusQueue.taskId = tasks.id
      ORDER BY focusQueue.position DESC
      ${limit != null && limit > 0 ? 'LIMIT $limit' : ''}
      ''',
    );

    return rows.map(taskFromRow).toList();
  }

  Future<int> getFocusedCount() async {
    final result = await db.get(
      '''
      SELECT COUNT(focusQueue.taskId) as count
      FROM focusQueue
      ''',
    );

    return result['count'] as int;
  }

  Future<void> focus(Task task, {int position = 0}) async {
    await db.writeTransaction((tx) async {
      await focusInContext([task], tx, position: position);
    });
  }

  Future<void> focusTasks(TaskList tasks, {int position = 0}) async {
    await db.writeTransaction((tx) async {
      await focusInContext(tasks, tx, position: position);
    });
  }

  Future<void> focusInContext(
    TaskList tasks,
    SqliteWriteContext tx, {
    int position = 0,
  }) {
    final taskIds = tasks.map(getTaskId).toList();

    return focusByIdsInContext(taskIds, tx, position: position);
  }

  Future<void> focusByIdsInContext(
    List<int> taskIds,
    SqliteWriteContext tx, {
    int position = 0,
  }) async {
    final taskLeaves = await leavesByIdsInContext(
      taskIds,
      tx,
      done: false,
    );
    final toAdd =
        (taskLeaves.isEmpty ? taskIds : taskLeaves.map(getTaskId).toList())
            .reversed
            .toList();

    await unfocusByIdsInContext(toAdd, tx);

    if (position == 0) {
      // get max value of position in focusQueue
      final result = await tx.get(
        'SELECT COALESCE(MAX(position) + 1, 0) as position FROM focusQueue',
      );
      final maxPosition = result['position'] as int;
      await tx.executeBatch(
        '''
        INSERT INTO focusQueue (taskId, position) VALUES (?, ?)
        ''',
        toAdd.mapIndexed((i, taskId) => [taskId, i + maxPosition]).toList(),
      );
    } else {
      final lengthResult = await tx.get(
        'SELECT count(taskId) as length FROM focusQueue',
      );
      final length = lengthResult['length'] as int;
      final realPosition = length - position;
      await tx.execute(
        '''
        UPDATE focusQueue
        SET position = position + ?
        WHERE position >= ?
        ''',
        [toAdd.length + 1, realPosition],
      );
      await tx.executeBatch(
        '''
          INSERT INTO focusQueue (taskId, position) VALUES (?, ?)
          ''',
        toAdd.indexed.map((item) {
          final (index, taskId) = item;

          return [taskId, realPosition + index];
        }).toList(),
      );
    }

    _broadcastUpdate();
  }

  Future<bool> isFocused(int? id, SqliteReadContext tx) async {
    if (id == null) return false;
    final result = await tx.get(
      'SELECT count(taskId) as count FROM focusQueue WHERE taskId = ?',
      [id],
    );

    return result['count'] as int > 0;
  }

  Future<void> unfocus(Task task) async {
    await unfocusInContext([task], db);
  }

  Future<void> unfocusInContext(TaskList tasks, SqliteWriteContext tx) =>
      unfocusByIdsInContext(tasks.map(getTaskId).toList(), tx);

  Future<void> unfocusByIdsInContext(
    List<int> ids,
    SqliteWriteContext tx,
  ) async {
    await tx.execute(
      'DELETE FROM focusQueue WHERE taskId IN (${questionMarks(ids.length)})',
      ids,
    );
    await _normalizeFocusQueuePositions(tx);
    _broadcastUpdate();
  }

  Future<void> _normalizeFocusQueuePositions(SqliteWriteContext tx) async {
    await tx.execute(
      '''
      UPDATE focusQueue
      SET position = p.newPosition
      FROM (
        SELECT taskId, position,
          (row_number() OVER (ORDER BY position) - 1) AS newPosition
        FROM focusQueue
        ORDER BY position
      ) AS p
      WHERE p.taskId = focusQueue.taskId
      ''',
    );
  }

  // TODO: Is there a better way to do this?
  Future<void> reprioritizeInFocusQueue(Task task, int position) async {
    await db.writeTransaction((tx) async {
      final lengthResult = await tx.get(
        'SELECT count(taskId) as length FROM focusQueue',
      );
      final length = lengthResult['length'] as int;
      final realPosition = length - position;
      await tx.execute(
        '''
        UPDATE focusQueue
        SET position = position + ?
        WHERE position >= ?
        ''',
        [1, realPosition],
      );
      await tx.execute(
        '''
        UPDATE focusQueue
        SET position = ?
        WHERE taskId = ?
        ''',
        [realPosition, task.id],
      );
      await _normalizeFocusQueuePositions(tx);
    });

    _broadcastUpdate();
  }

  Future<void> handleAddedTasksEvent(AddedTasksEvent event) async {
    final AddedTasksEvent(:parentId, :tasks, :tx) = event;
    if (parentId is int && await isFocused(parentId, tx)) {
      await unfocusByIdsInContext([parentId], tx);
      await focusInContext(tasks, tx);
    }
  }

  Future<void> handleUpdatedTaskEvent(UpdatedTaskEvent event) async {
    final UpdatedTaskEvent(:modified, :tx) = event;
    if (modified.hasToggledDone() && modified.done == true) {
      await unfocusInContext([modified], tx);
    } else {
      if (await isFocused(modified.id, tx)) {
        _broadcastUpdate();
      }
    }
  }

  Future<void> handleToggledTasksDoneEvent(ToggledTasksDoneEvent event) async {
    final ToggledTasksDoneEvent(:tasks, :tx, :doneAt) = event;
    if (doneAt != null) {
      await unfocusInContext(tasks, tx);
    }
  }

  Future<void> handleDeletedTaskEvent(DeletedTaskEvent event) async {
    _broadcastUpdate();
  }

  @override
  void registerEventHandlers(Diligent diligent) {
    diligent.register(handleAddedTasksEvent);
    diligent.register(handleUpdatedTaskEvent);
    diligent.register(handleToggledTasksDoneEvent);
    diligent.register(handleDeletedTaskEvent);
  }
}
