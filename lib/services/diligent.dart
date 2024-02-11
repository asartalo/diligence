import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:sqlite_async/sqlite3.dart';
import 'package:sqlite_async/sqlite_async.dart';

import '../models/modified_task.dart';
import '../models/new_task.dart';
import '../models/persisted_task.dart';
import '../models/task.dart';
import '../models/task_node.dart';
import 'migrations.dart';

typedef VoidCallback = void Function();
typedef TaskList = List<Task>;
typedef TaskNodeList = List<TaskNode>;

final initialAreas = [
  NewTask(name: 'Life', details: 'Life goals'),
  NewTask(name: 'Work', details: 'Work-related tasks'),
  NewTask(name: 'Projects', details: 'Personal projects'),
  NewTask(
    name: 'Miscellaneous',
    details: "Stuff that don't belong to the main areas",
  ),
  NewTask(name: 'Inbox', details: "Tasks that haven't been categorized yet"),
];

final _allTaskFields = [
  'id',
  'uid',
  'name',
  'details',
  'parentId',
  'doneAt',
  'expanded',
  'position',
  'createdAt',
  'updatedAt',
];

final _unmodifiableFields = ['id', 'uid'];

final _newTaskFields = _allTaskFields
    .where((field) => !['id', 'position'].contains(field))
    .toList();

final _modifiableFields = _allTaskFields
    .where((field) => !_unmodifiableFields.contains(field))
    .toList();

final _modifiableNonPositionFields =
    _modifiableFields.where((field) => field != 'position').toList();

final _queryCache = <String, String>{};

String _cachedQuery(String key, String query) {
  String? value = _queryCache[key];
  if (value == null) {
    _queryCache[key] = query;
    value = query;
  }
  return value;
}

String _prefixedField(String field, {String? prefix}) {
  return prefix is String ? '$prefix.$field' : field;
}

String _commaFields(List<String> fields, {String? prefix}) {
  return fields
      .map((field) => _prefixedField(field, prefix: prefix))
      .join(', ');
}

// Define a map for task fields
final taskFieldMap = {
  'id': (Task task) => task.id.toString(),
  'uid': (Task task) => task.uid,
  'name': (Task task) => task.name,
  'details': (Task task) => task.details,
  'parentId': (Task task) => task.parentId,
  'doneAt': (Task task) => task.doneAt?.millisecondsSinceEpoch,
  'expanded': (Task task) => task.expanded ? 1 : 0,
  'createdAt': (Task task) => task.createdAt.millisecondsSinceEpoch,
  'updatedAt': (Task task) => task.updatedAt.millisecondsSinceEpoch,
};

Object? _propFromTaskField(String field, Task task) {
  final mapping = taskFieldMap[field];
  if (mapping == null) {
    throw Exception('Unknown field: $field');
  }
  return mapping(task);
}

List<Object?> _propsFromTaskFields(List<String> fields, Task task) {
  return fields.map((field) => _propFromTaskField(field, task)).toList();
}

String _fieldValuePlaceholders(List<String> fields, {String? prefix}) {
  return fields
      .map((field) => '${_prefixedField(field, prefix: prefix)} = ?')
      .join(', ');
}

String _questionMarks(int count) {
  return List.generate(count, (_) => '?').join(', ');
}

SqliteMigrations migrate() {
  final SqliteMigrations migrations = SqliteMigrations();
  int i = 0;
  for (final migrationQuery in migrationQueries) {
    i += 1;
    migrations.add(SqliteMigration(i, (tx) async {
      await tx.execute(migrationQuery);
    }));
  }
  return migrations;
}

final migrations = migrate();

class Diligent {
  final SqliteDatabase db;
  final bool _isTest;

  Diligent({path = 'diligence.db'})
      : db = SqliteDatabase(path: path),
        _isTest = false;

  Diligent.forTests()
      : db = SqliteDatabase(path: 'test.db'),
        _isTest = true;

  Future<void> runMigrations() async {
    await migrations.migrate(db);
  }

  Future<void> clearDataForTests() async {
    if (_isTest) {
      await db.execute('DELETE FROM focusQueue');
      await db.execute('DELETE FROM tasks');
    }
  }

  Future<Task?> addTask(Task task, {int? position}) async {
    if (position != null) {
      await db.writeTransaction((tx) async {
        await tx.execute(
          '''
          UPDATE tasks SET position = position + 1
          WHERE parentId = ? AND position >= ?
          ''',
          [task.parentId, position],
        );
        await tx.execute(
          _cachedQuery(
            'taskInsertNoPosition',
            '''
            INSERT INTO tasks (${_newTaskFields.join(', ')}, position)
            SELECT ${_questionMarks(_newTaskFields.length + 1)}
            ''',
          ),
          [
            ..._propsFromTaskFields(_newTaskFields, task),
            position,
          ],
        );
      });
    } else {
      await db.execute(
        _cachedQuery(
          'taskInsertWithPosition',
          '''
          INSERT INTO tasks (${_newTaskFields.join(', ')}, position)
          SELECT ${_questionMarks(_newTaskFields.length)}, COALESCE(MAX(position) + 1, 0) FROM tasks WHERE parentId = ?
          ''',
        ),
        [
          ..._propsFromTaskFields(_newTaskFields, task),
          task.parentId,
        ],
      );
    }
    final result = await db.execute('SELECT last_insert_rowid() as id');
    return _asProvidedTask(task.copyWith(id: result.first['id'] as int));
  }

  Task _asProvidedTask(Task task) {
    if (task is PersistedTask) return task;
    return PersistedTask(
      id: task.id,
      parentId: task.parentId,
      doneAt: task.doneAt,
      uid: task.uid,
      name: task.name,
      details: task.details,
      expanded: task.expanded,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    );
  }

  Future<Task?> findTask(int id) async {
    final rows = await db.getAll('SELECT * FROM tasks WHERE id = ?', [id]);
    return rows.isEmpty ? null : _taskFromRow(rows.first);
  }

  Future<Task?> findTaskByName(String name) async {
    final rows = await db.getAll('SELECT * FROM tasks WHERE UPPER(name) LIKE ?',
        ["%${name.toUpperCase()}%"]);
    return rows.isEmpty ? null : _taskFromRow(rows.first);
  }

  Future<void> updateTask(Task task) async {
    if (task is ModifiedTask) {
      await db.writeTransaction((tx) async {
        await _updateTask(task, tx);
        await _focusCheck(task, tx);
        await _toggleTree(task, tx);
      });
    } else {
      throw Exception('Task must be a ModifiedTask');
    }
  }

  Future<void> _focusCheck(ModifiedTask task, SqliteWriteContext tx) async {
    if (task.hasToggledDone()) {
      if (task.done) {
        await _unfocus([task], tx);
      }
    }
  }

  /// _toggleTree toggles the doneAt field of its ancestors and descendants if
  /// applicable
  Future<void> _toggleTree(ModifiedTask task, SqliteWriteContext tx) async {
    if (task.hasToggledDone()) {
      await _toggleAncestorsDone(task, tx);
      await _toggleDescendantsDone(task, tx);
    }
  }

  // TODO: There must be a better way to do this using only a few queries
  Future<void> _toggleAncestorsDone(
    ModifiedTask task,
    SqliteWriteContext tx,
  ) async {
    final ancestors = await _ancestors(task, tx);
    final doneAt = task.doneAt;
    for (final ancestor in ancestors) {
      if (doneAt != null && await _allChildrenDone(ancestor, tx)) {
        await tx.execute(
          '''
          UPDATE tasks
          SET doneAt = ?
          WHERE id = ?
          ''',
          [doneAt.millisecondsSinceEpoch, ancestor.id],
        );
      } else if (doneAt == null && ancestor.done) {
        await tx.execute(
          '''
          UPDATE tasks
          SET doneAt = NULL
          WHERE id = ?
          ''',
          [ancestor.id],
        );
      }
    }
  }

  Future<void> _toggleDescendantsDone(
    ModifiedTask task,
    SqliteWriteContext tx,
  ) async {
    final descendants = await _descendants(task, tx);
    final doneAt = task.doneAt;
    for (final descendant in descendants) {
      await tx.execute(
        '''
        UPDATE tasks
        SET doneAt = ?
        WHERE id = ?
        ''',
        [doneAt?.millisecondsSinceEpoch, descendant.id],
      );
    }
    if (doneAt != null) {
      await _unfocus(descendants, tx);
    }
  }

  Future<bool> _allChildrenDone(Task task, SqliteReadContext tx) async {
    final result = await tx.get(
      '''
      SELECT count(id) as count, count(doneAt) as doneCount
      FROM tasks
      WHERE parentId = ?
      ''',
      [task.id],
    );
    final count = result['count'] as int;
    final doneCount = result['doneCount'] as int;
    return count == doneCount;
  }

  Future<TaskList> ancestors(Task task) async {
    return _ancestors(task, db);
  }

  Future<TaskList> _ancestors(Task task, SqliteWriteContext tx) async {
    final rows = await tx.getAll(
      _cachedQuery(
        'ancestors',
        '''
        WITH RECURSIVE
          ancestors AS (
            SELECT * FROM tasks WHERE id = ?
            UNION ALL
            SELECT tasks.* FROM tasks
            JOIN ancestors ON tasks.id = ancestors.parentId
          )
        SELECT * FROM ancestors
        ''',
      ),
      [task.parentId],
    );
    return rows.map((row) => _taskFromRow(row)).toList();
  }

  Future<TaskList> descendants(Task task) async {
    return _descendants(task, db);
  }

  Future<TaskList> _descendants(Task task, SqliteWriteContext tx) async {
    final rows = await tx.getAll(
      _cachedQuery(
        'descendants',
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
      ),
      [task.id],
    );
    return rows.map((row) => _taskFromRow(row)).toList();
  }

  Future<void> _updateTask(ModifiedTask task, SqliteWriteContext tx) async {
    await tx.execute(
      _cachedQuery(
        'updateTask',
        '''
          UPDATE tasks
          SET ${_fieldValuePlaceholders(_modifiableNonPositionFields)}
          WHERE id = ?
        ''',
      ),
      [
        ..._propsFromTaskFields(
          _modifiableNonPositionFields,
          task,
        ),
        task.id,
      ],
    );
  }

  Task _taskFromRow(Row row) {
    final task = PersistedTask(
      id: row['id'] as int,
      name: row['name'] as String,
      parentId: row['parentId'] as int?,
      doneAt: row['doneAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(row['doneAt'] as int)
          : null,
      uid: row['uid'] as String,
      expanded: row['expanded'] as int == 1,
      details: row['details'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updatedAt'] as int),
    );
    return task;
  }

  TaskNode _taskNodeFromRow(
    Row row, {
    required int level,
    int childrenCount = 0,
    int position = 0,
  }) {
    final task = _taskFromRow(row);
    return TaskNode(
      task: task,
      level: level,
      childrenCount: childrenCount,
      position: position,
    );
  }

  Future<void> deleteTask(Task task) async {
    await db.writeTransaction((tx) async {
      await tx.execute(
        'DELETE FROM tasks WHERE id = ?',
        [task.id],
      );
      await _reorderChildren(
        tx,
        task.parentId,
      );
    });
  }

  Future<void> _reorderChildren(SqliteWriteContext tx, int? parentId) async {
    await tx.execute(
      '''
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
      ''',
      [parentId, parentId],
    );
  }

  Future<void> moveTask(Task task, int position, {Task? parent}) async {
    if (parent is Task) {
      await _moveTaskToAnotherParent(task, parent, position);
    } else {
      await _moveTaskWithinSiblings(task, position);
    }
  }

  Future<void> _moveTaskToAnotherParent(
    Task task,
    Task parent,
    int position,
  ) async {
    await db.writeTransaction((tx) async {
      await tx.execute(
        '''
        UPDATE tasks
        SET position = position + 1
        WHERE parentId = ? AND position >= ?
        ''',
        [parent.id, position],
      );
      await tx.execute(
        '''
        UPDATE tasks
        SET parentId = ?, position = ?
        WHERE id = ?
        ''',
        [parent.id, position, task.id],
      );

      _reorderChildren(tx, task.parentId);
    });
  }

  Future<void> _moveTaskWithinSiblings(Task task, int position) async {
    await db.writeTransaction((tx) async {
      final (oldPosition, count) = await _getTaskPositionInfo(task, tx);
      final actualPosition = max(min(count - 1, position), 0);
      await tx.execute(
        '''
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
        ''',
        [
          oldPosition,
          actualPosition,
          oldPosition,
          actualPosition,
          oldPosition,
          actualPosition,
          task.parentId,
        ],
      );
    });
  }

  Future<(int, int)> _getTaskPositionInfo(
      Task task, SqliteReadContext tx) async {
    final positions = await tx.get(
      '''
      WITH siblings AS (
        SELECT id, (row_number() OVER (ORDER BY position) - 1) AS oldPosition
        FROM tasks
        WHERE parentId = ?
      )
      SELECT oldPosition, peers FROM siblings
      CROSS JOIN (SELECT count(id) AS peers FROM siblings)
      WHERE id = ?
      ''',
      [task.parentId, task.id],
    );
    return (positions['oldPosition'] as int, positions['peers'] as int);
  }

  Future<void> initialAreas(List<Task> areas) async {
    final root = await findTask(1);
    developer.log('root: $root');
    if (root != null) {
      return;
    }
    await addTask(NewTask(name: 'Root', id: 1, uid: 'root', expanded: true));
    for (final area in areas) {
      await addTask(area.copyWith(parentId: 1));
    }
  }

  FutureOr<List<Task>> getChildren(Task task) async {
    final rows = await db.getAll(
      'SELECT * FROM tasks WHERE parentId = ? ORDER BY position ASC',
      [task.id],
    );
    return rows.map((row) => _taskFromRow(row)).toList();
  }

  FutureOr<Task?> getParent(Task task) async {
    if (task.parentId == null) return null;
    final rows = await db.getAll(
      'SELECT * FROM tasks WHERE id = ?',
      [task.parentId],
    );
    return rows.isEmpty ? null : _taskFromRow(rows.first);
  }

  /// Returns a task and its descendants as an ordered list
  Future<TaskNodeList> subtreeFlat(int id) async {
    final rows = await db.getAll(
      _cachedQuery(
        'subtreeFlat',
        '''
          WITH RECURSIVE
            subtree(lvl, ${_commaFields(_allTaskFields)}) AS (
              SELECT
                0 AS lvl,
                ${_commaFields(_allTaskFields)}
              FROM tasks
              WHERE id = ?
            UNION ALL
              SELECT
                subtree.lvl + 1,
                ${_commaFields(_allTaskFields, prefix: 'tasks')}
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
      ),
      [id],
    );
    return rows
        .map((row) => _taskNodeFromRow(
              row,
              level: row['lvl'] as int,
              childrenCount: row['childrenCount'] as int,
              position: row['position'] as int,
            ))
        .toList();
  }

  Future<TaskNodeList> expandedDescendantsTree(Task task) async {
    final id = task.id;
    final rows = await db.getAll(
      _cachedQuery(
        'expandedDescendantsTree',
        '''
          WITH RECURSIVE
            subtree(lvl, ${_commaFields(_allTaskFields)}) AS (
              SELECT
                0 AS lvl,
                ${_commaFields(_allTaskFields, prefix: 'tasks')}
              FROM tasks
              WHERE tasks.parentId = ?
            UNION ALL
              SELECT
                subtree.lvl + 1,
                ${_commaFields(_allTaskFields, prefix: 'tasks')}
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
      ),
      [id],
    );
    return rows
        .map((row) => _taskNodeFromRow(
              row,
              level: row['lvl'] as int,
              childrenCount: row['childrenCount'] as int,
              position: row['position'] as int,
            ))
        .toList();
  }

  Future<TaskList> leaves(Task task) {
    return _leaves(task, db);
  }

  Future<TaskList> _leaves(Task task, SqliteReadContext tx) async {
    final id = task.id;
    final rows = await tx.getAll(
      _cachedQuery(
        'leaves',
        '''
          WITH RECURSIVE
            subtree(lvl, ${_commaFields(_allTaskFields)}) AS (
              SELECT
                0 AS lvl,
                ${_commaFields(_allTaskFields, prefix: 'tasks')}
              FROM tasks
              WHERE tasks.parentId = ?
            UNION ALL
              SELECT
                subtree.lvl + 1,
                ${_commaFields(_allTaskFields, prefix: 'tasks')}
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
        ''',
      ),
      [id],
    );
    return rows.map((row) => _taskFromRow(row)).toList();
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
    return rows.map((row) => _taskFromRow(row)).toList();
  }

  Future<void> focus(Task task, {int position = 0}) async {
    await db.writeTransaction((tx) async {
      final taskLeaves = await _leaves(task, tx);
      final toAdd = taskLeaves.isEmpty ? [task] : taskLeaves;

      await _unfocus(toAdd, tx);

      if (position == 0) {
        await tx.executeBatch(
          '''
          INSERT INTO focusQueue (taskId, position) VALUES (?, (
            SELECT COALESCE(MAX(position) + 1, 0) FROM focusQueue
          ))
          ''',
          toAdd.reversed.map((task) => [task.id]).toList(),
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
          toAdd.reversed.indexed.map((item) {
            final (index, task) = item;
            return [task.id, realPosition + index];
          }).toList(),
        );
      }
    });
  }

  Future<void> unfocus(Task task) async {
    await db.writeTransaction((tx) async {
      await _unfocus([task], tx);
    });
  }

  Future<void> _unfocus(List<Task> tasks, SqliteWriteContext tx) async {
    await tx.executeBatch(
      '''
      DELETE FROM focusQueue WHERE taskId = ?
      ''',
      tasks.map((task) => [task.id]).toList(),
    );

    await tx.execute(
      // Reorder positions
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
    });
  }
}
