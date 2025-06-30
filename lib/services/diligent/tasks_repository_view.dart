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

import 'package:sqlite_async/sqlite3.dart';
import 'package:sqlite_async/sqlite_async.dart';

import '../../models/persisted_task.dart';
import '../../models/task.dart';
import '../../models/task_list.dart';
import '../../utils/clock.dart';
import '../../utils/date_time_from_row_epoch.dart';
import 'task_fields.dart';

class TasksRepositoryView {
  final Clock clock;

  final SqliteReadContext _tx;

  TasksRepositoryView({required this.clock, required SqliteWriteContext tx})
    : _tx = tx;

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
}
