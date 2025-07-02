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

import 'dart:math';

import 'package:collection/collection.dart';
import 'package:sqlite_async/sqlite_async.dart';

import 'new_task.dart';
import 'modified_task.dart';
import 'task.dart';
import 'task_list.dart';
import '../../../utils/clock.dart';
import '../../../utils/date_time_from_row_epoch.dart';
import '../task_fields.dart';
import 'tasks_db_reader.dart';

typedef TasksCallback = Future<void> Function(List<Task> tasks);

class TasksDbWriterResult {
  TaskList addedTasks = [];
  TaskList deletedTasks = [];
  TaskList updatedTasks = [];
  TaskList toggledTasks = [];

  Map<DateTime?, TaskList> toggledTasksGroupedByDoneAt() {
    final grouped = <DateTime?, TaskList>{};
    for (var task in toggledTasks) {
      grouped[task.doneAt] ??= [];
      grouped[task.doneAt]!.add(task);
    }

    return grouped;
  }
}

class TasksDbWriterTransactionError extends AssertionError {
  TasksDbWriterTransactionError(super.message);
}

class TasksDbWriter {
  final Clock clock;

  final SqliteWriteContext _tx;

  final TasksDbReader _view;

  // TasksDbWriter exists per transaction. If the transaction is closed, this
  // should no longer be used.
  bool get transactionDone => _tx.closed;

  TasksDbWriter({
    required this.clock,
    required SqliteWriteContext tx,
    required TasksDbReader view,
  }) : _tx = tx,
       _view = view;

  static NewTask newTask({
    int id = 0,
    int? parentId,
    Task? parent,
    bool? done,
    DateTime? doneAt,
    String? uid,
    String? name,
    String? details,
    bool? expanded,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deadlineAt,
    required DateTime now,
  }) {
    return NewTask(
      id: id,
      parentId: parentId,
      parent: parent,
      doneAt: doneAt,
      uid: uid,
      name: name ?? '',
      details: details,
      expanded: expanded ?? false,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deadlineAt: deadlineAt,
      now: now,
    );
  }

  void _checkTransactionPossible() {
    if (transactionDone) {
      throw TasksDbWriterTransactionError(
        'Transaction has been used is and no longer available.',
      );
    }
  }

  static const _addTaskAdjustPositionQuery = '''
    UPDATE tasks SET position = position + ?
    WHERE parentId = ? AND position >= ?
    ''';

  Future<TasksDbWriterResult> addTask(TaskList tasks, {int? position}) async {
    _checkTransactionPossible();
    final result = TasksDbWriterResult();
    await _validateAddedTasks(tasks);
    final parentId = tasks.first.parentId;

    final positionToUse = position ?? await _getChildLastPosition(parentId);

    await _tx.execute(_addTaskAdjustPositionQuery, [
      tasks.length,
      parentId,
      positionToUse,
    ]);
    final batchProps = tasks.mapIndexed((int index, task) {
      return [
        ...propsFromTaskFields(newTaskFields, task),
        positionToUse + index,
      ];
    }).toList();
    await _tx.executeBatch('''
        INSERT INTO tasks (${newTaskFields.join(', ')}, position)
        SELECT ${questionMarks(newTaskFields.length + 1)}
        ''', batchProps);

    result.addedTasks = await _getPersistedTasks(tasks);
    await _toggleLineage(result.addedTasks.first, result: result);

    return result;
  }

  Future<TasksDbWriterResult> updateTask(Task task) async {
    _checkTransactionPossible();
    if (task is! ModifiedTask) {
      throw ArgumentError('Task must be a ModifiedTask');
    }
    final result = TasksDbWriterResult();
    late Task? updatedTask;
    await _updateTask(task);
    await _toggleTreeIfToggled(task, result: result);
    updatedTask = await _view.findTask(task.id);
    if (updatedTask == null) {
      throw Exception('Task was not updated.');
    }

    result.updatedTasks.add(updatedTask);

    return result;
  }

  Future<TasksDbWriterResult> deleteTask(Task task) async {
    _checkTransactionPossible();
    final result = TasksDbWriterResult();
    await _tx.execute('DELETE FROM tasks WHERE id = ?', [task.id]);
    await _reorderChildren(task.parentId);
    final parent = await _view.findTask(task.parentId);
    if (parent is Task) {
      await _toggleLineage(task, result: result);
    }
    result.deletedTasks.add(task);

    return result;
  }

  Future<TasksDbWriterResult> moveTask(
    Task task,
    int position, {
    Task? parent,
  }) async {
    _checkTransactionPossible();
    final result = TasksDbWriterResult();
    if (parent is Task && parent.id != task.parentId) {
      await _moveTaskToAnotherParent(task, parent, position, result);
    } else {
      await _moveTaskWithinSiblings(task, position, result);
    }

    return result;
  }

  Future<void> _validateAddedTasks(TaskList tasks) async {
    final Set<int?> parentIds = {};
    for (final task in tasks) {
      task.validate();
      parentIds.add(task.parentId ?? 0);
    }
    if (parentIds.length > 1) {
      throw ArgumentError('All tasks must have the same parent.');
    }
    final parentId = parentIds.first;
    if (parentId != 0) {
      final parent = await _view.findTask(parentId);
      if (parent == null) {
        throw ArgumentError('Parent with id $parentId does not exist.');
      }
    }
  }

  static const _childPositionQuery = '''
    SELECT COALESCE(MAX(position) + 1, 0) as lastPosition
    FROM tasks
    WHERE parentId = ?
    ''';

  Future<int> _getChildLastPosition(int? parentId) async {
    final lastPositionResult = await _tx.get(_childPositionQuery, [parentId]);

    return lastPositionResult.isNotEmpty
        ? lastPositionResult['lastPosition'] as int
        : 0;
  }

  Future<TaskList> _getPersistedTasks(TaskList tasks) async {
    final uids = _uidsFromTasks(tasks);
    final newTasks = await _view.findTasksByUids(uids);

    if (newTasks.length != uids.length) {
      throw Exception('Not all tasks were created.');
    }

    return newTasks;
  }

  List<String> _uidsFromTasks(TaskList tasks) {
    return tasks.map((task) => task.uid).toList();
  }

  Future<void> _toggleLineage(
    Task task, {
    required TasksDbWriterResult result,
    bool forceDescendants = false,
    bool startAtTask = false,
  }) async {
    await _toggleAncestorsDone(task, result: result, startAtTask: startAtTask);
    if (forceDescendants) {
      await _toggleDescendantsDone(task, result: result);
    }
  }

  // TODO: There must be a better way to do this using only a few queries
  Future<void> _toggleAncestorsDone(
    Task task, {
    required TasksDbWriterResult result,
    bool startAtTask = false,
  }) async {
    final ancestors = await _view.ancestors(
      task,
      includeTaskAsAncestor: startAtTask,
      reverse: false,
    );
    for (final ancestor in ancestors) {
      final doneAt = await _allChildrenDone(ancestor);
      if (
      // ancestor is done and task is not done
      (doneAt == null && ancestor.done) ||
          // ancestor is not done and all children are done
          (doneAt is DateTime &&
              (doneAt.millisecondsSinceEpoch !=
                  ancestor.doneAt?.millisecondsSinceEpoch))) {
        result.toggledTasks.add(ancestor);
        await _toggleDoneById(doneAt?.millisecondsSinceEpoch, ancestor.id);
      } else {
        break;
      }
    }
  }

  static const _allChildrenDoneQuery = '''
    SELECT COUNT(id) as count,
      COUNT(doneAt) as doneCount,
      MAX(COALESCE(doneAt, 0)) as latestDoneAt
    FROM tasks
    WHERE parentId = ?
    ''';

  Future<DateTime?> _allChildrenDone(Task task) async {
    final result = await _tx.get(_allChildrenDoneQuery, [task.id]);
    final count = result['count'] as int;
    final doneCount = result['doneCount'] as int;
    final doneAtEpoch = result['latestDoneAt'] == null
        ? 0
        : result['latestDoneAt'] as int;
    final doneAt = doneAtEpoch > 0 ? dateTimeFromRowEpoch(doneAtEpoch) : null;

    return count == doneCount ? doneAt : null;
  }

  static const _toggleDoneByIdQuery =
      'UPDATE tasks SET doneAt = ? WHERE id = ?';

  Future<void> _toggleDoneById(int? doneAtEpoch, int id) =>
      _tx.execute(_toggleDoneByIdQuery, [doneAtEpoch, id]);

  static const _toggleDescendantsDoneQuery = '''
    UPDATE tasks
    SET doneAt = ?
    WHERE id = ?
    ''';

  Future<void> _toggleDescendantsDone(
    Task task, {
    required TasksDbWriterResult result,
  }) async {
    final descendants = await _view.descendants(task);
    final doneAt = task.doneAt;

    for (final descendant in descendants) {
      await _tx.execute(_toggleDescendantsDoneQuery, [
        doneAt?.millisecondsSinceEpoch,
        descendant.id,
      ]);
    }
    result.toggledTasks.addAll(descendants);
  }

  Future<void> _updateTask(ModifiedTask task) async {
    await _tx.execute(
      '''
      UPDATE tasks
      SET ${fieldValuePlaceholders(modifiableNonPositionFields)}
      WHERE id = ?
      ''',
      [...propsFromTaskFields(modifiableNonPositionFields, task), task.id],
    );
  }

  Future<void> _toggleTreeIfToggled(
    ModifiedTask task, {
    required TasksDbWriterResult result,
  }) async {
    if (task.hasToggledDone()) {
      await _toggleLineage(task, forceDescendants: true, result: result);
    }
  }

  static const _reorderChildrenQuery = '''
    UPDATE tasks
    SET position = p.newPosition
    FROM (
      SELECT id, position,
        (row_number() OVER (ORDER BY position) - 1) AS newPosition
      FROM tasks
      WHERE parentId = ?
      ORDER BY position
    ) AS p
    WHERE p.id = tasks.id
    AND parentId = ?
    ''';

  Future<void> _reorderChildren(int? parentId) async {
    await _tx.execute(_reorderChildrenQuery, [parentId, parentId]);
  }

  static const _adjustAfterSiblingsDownQuery = '''
    UPDATE tasks
    SET position = position + 1
    WHERE parentId = ? AND position >= ?
    ''';

  static const _addhildToParentQuery = '''
    UPDATE tasks
    SET parentId = ?, position = ?
    WHERE id = ?
    ''';

  Future<void> _moveTaskToAnotherParent(
    Task task,
    Task parent,
    int position,
    TasksDbWriterResult result,
  ) async {
    await _tx.execute(_adjustAfterSiblingsDownQuery, [parent.id, position]);
    await _tx.execute(_addhildToParentQuery, [parent.id, position, task.id]);

    await _toggleLineage(parent, startAtTask: true, result: result);
    await _reorderChildren(task.parentId);
    final oldParent = await _view.findTask(task.parentId);
    if (oldParent is Task) {
      await _toggleLineage(oldParent, startAtTask: true, result: result);
    }
  }

  static const _moveTaskWithinSiblingsQuery = '''
    UPDATE tasks
    SET position = (
      CASE
      WHEN p.oldPosition < ? AND p.oldPosition >= ?
        THEN p.oldPosition + 1
      WHEN p.oldPosition > ? AND p.oldPosition <= ?
        THEN p.oldPosition - 1
      WHEN p.oldPosition = ? THEN ?
      ELSE p.oldPosition
      END
    )
    FROM (
      SELECT id, position,
        (row_number() OVER (ORDER BY position) - 1) AS oldPosition
      FROM tasks
      WHERE parentId = ?
      ORDER BY position
    ) AS p
    WHERE p.id = tasks.id
    ''';

  Future<void> _moveTaskWithinSiblings(
    Task task,
    int position,
    TasksDbWriterResult result,
  ) async {
    final (oldPosition, count) = await _getTaskPositionInfo(task);
    final actualPosition = max(min(count - 1, position), 0);
    await _tx.execute(_moveTaskWithinSiblingsQuery, [
      oldPosition,
      actualPosition,
      oldPosition,
      actualPosition,
      oldPosition,
      actualPosition,
      task.parentId,
    ]);
  }

  static const _getTaskPositionInfoQuery = '''
    WITH siblings AS (
      SELECT id, (row_number() OVER (ORDER BY position) - 1) AS oldPosition
      FROM tasks
      WHERE parentId = ?
    )
    SELECT oldPosition, peers FROM siblings
    CROSS JOIN (SELECT count(id) AS peers FROM siblings)
    WHERE id = ?
    ''';

  Future<(int, int)> _getTaskPositionInfo(Task task) async {
    final positions = await _tx.get(_getTaskPositionInfoQuery, [
      task.parentId,
      task.id,
    ]);

    return (positions['oldPosition'] as int, positions['peers'] as int);
  }
}
