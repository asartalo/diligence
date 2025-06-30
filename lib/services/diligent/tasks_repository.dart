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

import 'package:collection/collection.dart';
import 'package:sqlite_async/sqlite3.dart';
import 'package:sqlite_async/sqlite_async.dart';

import '../../models/new_task.dart';
import '../../models/persisted_task.dart';
import '../../models/modified_task.dart';
import '../../models/task.dart';
import '../../models/task_list.dart';
import '../../utils/clock.dart';
import '../../utils/date_time_from_row_epoch.dart';
import 'task_fields.dart';
import 'tasks_repository_view.dart';

typedef TasksCallback = Future<void> Function(List<Task> tasks);

class TasksRepositoryResult {
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

class TasksRepositoryTransactionError extends AssertionError {
  TasksRepositoryTransactionError(super.message);
}

class TasksRepository {
  final Clock clock;

  final SqliteWriteContext _tx;

  final TasksRepositoryView _view;

  // TasksRepository exists per transaction. If the transaction is closed, this
  // should no longer be used.
  bool get transactionDone => _tx.closed;

  TasksRepository({
    required this.clock,
    required SqliteWriteContext tx,
    required TasksRepositoryView view,
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
      throw TasksRepositoryTransactionError(
        'Transaction has been used is and no longer available.',
      );
    }
  }

  Future<TasksRepositoryResult> addTask(TaskList tasks, {int? position}) async {
    _checkTransactionPossible();
    final result = TasksRepositoryResult();
    await _validateAddedTasks(tasks);
    final parentId = tasks.first.parentId;

    final positionToUse = position ?? await _getChildLastPosition(parentId);

    await _tx.execute(
      '''
        UPDATE tasks SET position = position + ?
        WHERE parentId = ? AND position >= ?
        ''',
      [tasks.length, parentId, positionToUse],
    );
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

  Future<int> _getChildLastPosition(int? parentId) async {
    final lastPositionResult = await _tx.get(
      '''
      SELECT COALESCE(MAX(position) + 1, 0) as lastPosition
      FROM tasks
      WHERE parentId = ?
      ''',
      [parentId],
    );

    return lastPositionResult.isNotEmpty
        ? lastPositionResult['lastPosition'] as int
        : 0;
  }

  Task _taskFromRow(Row row) {
    final task = PersistedTask(
      id: row['id'] as int,
      name: row['name'] as String,
      parentId: row['parentId'] as int?,
      doneAt: row['doneAt'] != null
          ? dateTimeFromRowEpoch(row['doneAt'])
          : null,
      uid: row['uid'] as String,
      expanded: row['expanded'] as int == 1,
      details: row['details'] as String?,
      createdAt: dateTimeFromRowEpoch(row['createdAt']),
      updatedAt: dateTimeFromRowEpoch(row['updatedAt']),
      deadlineAt: row['deadlineAt'] != null
          ? dateTimeFromRowEpoch(row['deadlineAt'])
          : null,
    );

    return task;
  }

  Future<TaskList> _getPersistedTasks(TaskList tasks) async {
    final uids = _uidsFromTasks(tasks);
    final newTasks = await _findTasksByUids(uids);

    if (newTasks.length != uids.length) {
      throw Exception('Not all tasks were created.');
    }

    return newTasks;
  }

  List<String> _uidsFromTasks(TaskList tasks) {
    return tasks.map((task) => task.uid).toList();
  }

  Future<TaskList> _findTasksByUids(List<String> uids) async {
    final qMarks = questionMarks(uids.length);
    final rows = await _tx.getAll('''
      SELECT * FROM tasks WHERE uid IN ($qMarks) ORDER BY position
      ''', uids);

    return rows.map(_taskFromRow).toList();
  }

  Future<void> _toggleLineage(
    Task task, {
    required TasksRepositoryResult result,
    bool forceDescendants = false,
    bool startAtTask = false,
  }) async {
    if (task.name == 'A1i - leaf') {}
    await _toggleAncestorsDone(task, result: result, startAtTask: startAtTask);
    if (forceDescendants) {
      await _toggleDescendantsDone(task, result: result);
    }
  }

  // TODO: There must be a better way to do this using only a few queries
  Future<void> _toggleAncestorsDone(
    Task task, {
    required TasksRepositoryResult result,
    bool startAtTask = false,
  }) async {
    final ancestors = await _ancestors(
      task,
      includeTaskAsAncestor: startAtTask,
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

  Future<DateTime?> _allChildrenDone(Task task) async {
    final result = await _tx.get(
      '''
      SELECT COUNT(id) as count,
        COUNT(doneAt) as doneCount,
        MAX(COALESCE(doneAt, 0)) as latestDoneAt
      FROM tasks
      WHERE parentId = ?
      ''',
      [task.id],
    );
    final count = result['count'] as int;
    final doneCount = result['doneCount'] as int;
    final doneAtEpoch = result['latestDoneAt'] == null
        ? 0
        : result['latestDoneAt'] as int;
    final doneAt = doneAtEpoch > 0 ? dateTimeFromRowEpoch(doneAtEpoch) : null;

    return count == doneCount ? doneAt : null;
  }

  Future<void> _toggleDoneById(int? doneAtEpoch, int id) => _tx.execute(
    'UPDATE tasks SET doneAt = ? WHERE id = ?',
    [doneAtEpoch, id],
  );

  Future<void> _toggleDescendantsDone(
    Task task, {
    required TasksRepositoryResult result,
  }) async {
    final descendants = await _descendants(task, _tx);
    final doneAt = task.doneAt;

    for (final descendant in descendants) {
      await _tx.execute(
        '''
        UPDATE tasks
        SET doneAt = ?
        WHERE id = ?
        ''',
        [doneAt?.millisecondsSinceEpoch, descendant.id],
      );
    }
    result.toggledTasks.addAll(descendants);
  }

  Future<TaskList> _descendants(Task task, SqliteWriteContext tx) async {
    final rows = await tx.getAll(
      '''
      WITH RECURSIVE
        descendants AS (
          SELECT * FROM tasks WHERE parentId = ?
          UNION ALL
          SELECT tasks.* FROM tasks
          JOIN descendants ON tasks.parentId = descendants.id
        )
      SELECT * FROM descendants
      ''',
      [task.id],
    );

    return rows.map(_taskFromRow).toList();
  }

  static const String _ancestorsQuery = '''
        WITH RECURSIVE
          ancestors AS (
            SELECT * FROM tasks WHERE id = ?
            UNION ALL
            SELECT tasks.* FROM tasks
            JOIN ancestors ON tasks.id = ancestors.parentId
          )
        SELECT * FROM ancestors
        ''';

  static const String _ancestorsQueryReverse = '''
        WITH RECURSIVE
          ancestors AS (
            SELECT *, 0 AS lvl FROM tasks WHERE id = ?
            UNION ALL
            SELECT tasks.*, ancestors.lvl + 1 FROM tasks
            JOIN ancestors ON tasks.id = ancestors.parentId
          )
        SELECT * FROM ancestors
        ORDER BY lvl DESC;
        ''';

  Future<TaskList> _ancestors(
    Task task, {
    bool includeTaskAsAncestor = false,
    bool reverse = false,
  }) async {
    final id = includeTaskAsAncestor ? task.id : task.parentId;
    final rows = await _tx.getAll(
      reverse ? _ancestorsQueryReverse : _ancestorsQuery,
      [id],
    );

    return rows.map(_taskFromRow).toList();
  }

  Future<TasksRepositoryResult> updateTask(Task task) async {
    _checkTransactionPossible();
    if (task is! ModifiedTask) {
      throw ArgumentError('Task must be a ModifiedTask');
    }
    final result = TasksRepositoryResult();
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
    required TasksRepositoryResult result,
  }) async {
    if (task.hasToggledDone()) {
      await _toggleLineage(task, forceDescendants: true, result: result);
    }
  }
}
