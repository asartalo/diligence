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

import 'dart:async';

import 'package:sqlite_async/sqlite3.dart';
import 'package:sqlite_async/sqlite_async.dart';

import 'persisted_task.dart';
import 'task.dart';
import 'task_list.dart';
import 'task_node.dart';
import '../../../utils/date_time_from_row_epoch.dart';
import '../diligent.dart';
import '../task_fields.dart';

class TasksDbReader {
  final SqliteReadContext _tx;

  TasksDbReader({required SqliteReadContext tx}) : _tx = tx;

  Future<Task?> findTask(int? id) => _findTask(id);

  Future<Task?> _findTask(int? id) async {
    if (id == null) return null;
    final rows = await _tx.getAll('SELECT * FROM tasks WHERE id = ?', [id]);

    return rows.isEmpty ? null : taskFromRow(rows.first);
  }

  Future<TaskList> findTasksByUids(List<String> uids) async {
    final qMarks = questionMarks(uids.length);
    final rows = await _tx.getAll('''
      SELECT * FROM tasks WHERE uid IN ($qMarks) ORDER BY position
      ''', uids);

    return rows.map(taskFromRow).toList();
  }

  Future<Task?> findTaskByName(String name) async {
    final rows = await _tx.getAll(
      'SELECT * FROM tasks WHERE UPPER(name) LIKE ?',
      ["%${name.toUpperCase()}%"],
    );

    return rows.isEmpty ? null : taskFromRow(rows.first);
  }

  Task taskFromRow(Row row) {
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

  Future<TaskList> ancestors(
    Task task, {
    bool includeTaskAsAncestor = false,
    bool reverse = true,
  }) => _ancestors(
    task,
    includeTaskAsAncestor: includeTaskAsAncestor,
    reverse: reverse,
  );

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

    return rows.map(taskFromRow).toList();
  }

  Future<TaskList> descendants(Task task) => _descendants(task);

  static const _descendantsQuery = '''
    WITH RECURSIVE
      descendants AS (
        SELECT * FROM tasks WHERE parentId = ?
        UNION ALL
        SELECT tasks.* FROM tasks
        JOIN descendants ON tasks.parentId = descendants.id
      )
    SELECT * FROM descendants
    ''';

  Future<TaskList> _descendants(Task task) async {
    final rows = await _tx.getAll(_descendantsQuery, [task.id]);

    return rows.map(taskFromRow).toList();
  }

  static const _getChildrenQuery =
      'SELECT * FROM tasks WHERE parentId = ? ORDER BY position ASC';

  FutureOr<TaskList> getChildren(Task task) async {
    final rows = await _tx.getAll(_getChildrenQuery, [task.id]);

    return rows.map(taskFromRow).toList();
  }

  static const _getParentQuery = 'SELECT * FROM tasks WHERE id = ?';
  FutureOr<Task?> getParent(Task task) async {
    if (task.parentId == null) return null;
    final rows = await _tx.getAll(_getParentQuery, [task.parentId]);

    return rows.isEmpty ? null : taskFromRow(rows.first);
  }

  /// Returns a task and its descendants as an ordered list
  Future<TaskNodeList> subtreeFlat(int id) async {
    final rows = await _tx.getAll(
      '''
      WITH RECURSIVE
        subtree(lvl, $commaAllTaskFields) AS (
          SELECT
            0 AS lvl,
            $commaAllTaskFields
          FROM tasks
          WHERE id = ?
        UNION ALL
          SELECT
            subtree.lvl + 1,
            ${commaFields(allTaskFields, prefix: 'tasks')}
          FROM
            subtree
            JOIN tasks ON tasks.parentId = subtree.id
          ORDER BY
            subtree.lvl+1 DESC,
            tasks.position
        )
      SELECT
        subtree.*,
        (
          SELECT count(id)
          FROM tasks
          WHERE parentId = subtree.id
        ) AS childrenCount
      FROM subtree
      ''',
      [id],
    );

    return rows
        .map(
          (row) => _taskNodeFromRow(
            row,
            level: row['lvl'] as int,
            childrenCount: row['childrenCount'] as int,
            position: row['position'] as int,
          ),
        )
        .toList();
  }

  Future<TaskNodeList> expandedDescendantsTree(Task task) async {
    final id = task.id;
    final rows = await _tx.getAll(
      '''
      WITH RECURSIVE
        subtree(lvl, $commaAllTaskFields) AS (
          SELECT
            0 AS lvl,
            $commaAllTaskFieldsPrefixed
          FROM tasks
          WHERE tasks.parentId = ?
        UNION ALL
          SELECT
            subtree.lvl + 1,
            $commaAllTaskFieldsPrefixed
          FROM
            subtree
            JOIN tasks ON tasks.parentId = subtree.id
          WHERE subtree.expanded = 1
          ORDER BY
            subtree.lvl+1 DESC,
            tasks.position
        )
      SELECT
        subtree.*,
        (
          SELECT count(id)
          FROM tasks
          WHERE parentId = subtree.id
        ) AS childrenCount
      FROM subtree
      ''',
      [id],
    );

    return rows
        .map(
          (row) => _taskNodeFromRow(
            row,
            level: row['lvl'] as int,
            childrenCount: row['childrenCount'] as int,
            position: row['position'] as int,
          ),
        )
        .toList();
  }

  TaskNode _taskNodeFromRow(
    Row row, {
    required int level,
    int childrenCount = 0,
    int position = 0,
  }) {
    final task = taskFromRow(row);

    return TaskNode(
      task: task,
      level: level,
      childrenCount: childrenCount,
      position: position,
    );
  }

  int getTaskId(Task task) => task.id;

  Future<TaskList> leaves(TaskList tasks, {bool? done}) async {
    final ids = tasks.map(getTaskId).toList();
    return leavesByIdsInContext(ids, done: done);
  }

  Future<TaskList> leavesByIdsInContext(List<int> ids, {bool? done}) async {
    String doneClause = '';
    if (done is bool) {
      doneClause = 'AND doneAt IS ${done ? 'NOT' : ''} NULL';
    }
    final rows = await _tx.getAll('''
      WITH RECURSIVE
        subtree(lvl, $commaAllTaskFields) AS (
          SELECT
            0 AS lvl,
            $commaAllTaskFieldsPrefixed
          FROM tasks
          WHERE tasks.parentId IN (${questionMarks(ids.length)})
        UNION ALL
          SELECT
            subtree.lvl + 1,
            $commaAllTaskFieldsPrefixed
          FROM
            subtree
            JOIN tasks ON tasks.parentId = subtree.id
          ORDER BY
            subtree.lvl+1 DESC,
            tasks.position
        )
      SELECT
        subtree.*,
        (
          SELECT count(id)
          FROM tasks
          WHERE parentId = subtree.id
        ) AS childrenCount
      FROM subtree
      WHERE childrenCount = 0
      $doneClause
      ''', ids);

    return rows.map(taskFromRow).toList();
  }
}
