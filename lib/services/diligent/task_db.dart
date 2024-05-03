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

import 'package:sqlite_async/sqlite3.dart';
import 'package:sqlite_async/sqlite_async.dart';

import '../../models/persisted_task.dart';
import '../../models/task.dart';
import '../../models/task_list.dart';
import '../../utils/date_time_from_row_epoch.dart';
import 'task_fields.dart';

abstract class TaskDb {
  SqliteDatabase get db;

  int getTaskId(Task task) => task.id;

  Task taskFromRow(Row row) {
    final task = PersistedTask(
      id: row['id'] as int,
      name: row['name'] as String,
      parentId: row['parentId'] as int?,
      doneAt:
          row['doneAt'] != null ? dateTimeFromRowEpoch(row['doneAt']) : null,
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

  Future<TaskList> leavesInContext(
    TaskList tasks,
    SqliteReadContext tx, {
    bool? done,
  }) async {
    final ids = tasks.map(getTaskId).toList();
    return leavesByIdsInContext(ids, tx, done: done);
  }

  Future<TaskList> leavesByIdsInContext(
    List<int> ids,
    SqliteReadContext tx, {
    bool? done,
  }) async {
    String doneClause = '';
    if (done is bool) {
      doneClause = 'AND doneAt IS ${done ? 'NOT' : ''} NULL';
    }
    final rows = await tx.getAll(
      '''
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
      ''',
      ids,
    );

    return rows.map(taskFromRow).toList();
  }
}
