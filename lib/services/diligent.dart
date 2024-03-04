import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:sqlite_async/sqlite3.dart';
import 'package:sqlite_async/sqlite_async.dart';

import '../models/modified_task.dart';
import '../models/new_task.dart';
import '../models/persisted_task.dart';
import '../models/task.dart';
import '../models/task_node.dart';
import 'migrations.dart';

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

int _getTaskId(Task task) => task.id;

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

  final _queryCache = <String, String>{};

  String _cachedQuery(String key, String query) {
    String? value = _queryCache[key];
    if (value == null) {
      _queryCache[key] = query;
      value = query;
    }
    return value;
  }

  Future<void> _validateAddedTasks(
    TaskList tasks,
    SqliteReadContext tx,
  ) async {
    final Set<int?> parentIds = {};
    for (final task in tasks) {
      if (task.name.isEmpty) {
        throw ArgumentError('Task name must not be empty.');
      }
      parentIds.add(task.parentId ?? 0);
    }
    if (parentIds.length > 1) {
      throw ArgumentError('All tasks must have the same parent.');
    }
    final parentId = parentIds.first;
    if (parentId != 0) {
      final parent = await _findTask(parentId, tx);
      if (parent == null) {
        throw ArgumentError('Parent with id $parentId does not exist.');
      }
    }
  }

  Future<TaskList> addTasks(TaskList tasks, {int? position}) async {
    TaskList newTasks = [];

    await db.writeTransaction((tx) async {
      await _validateAddedTasks(tasks, tx);
      final parentId = tasks.first.parentId;

      final positionToUse =
          position ?? await _getChildLastPosition(parentId, tx);

      await tx.execute(
        '''
        UPDATE tasks SET position = position + ?
        WHERE parentId = ? AND position >= ?
        ''',
        [tasks.length, parentId, positionToUse],
      );
      final batchProps = tasks.mapIndexed((int index, task) {
        return [
          ..._propsFromTaskFields(_newTaskFields, task),
          positionToUse + index,
        ];
      }).toList();
      await tx.executeBatch(
        _cachedQuery(
          'tasksInsertWithPosition',
          '''
          INSERT INTO tasks (${_newTaskFields.join(', ')}, position)
          SELECT ${_questionMarks(_newTaskFields.length + 1)}
          ''',
        ),
        batchProps,
      );

      newTasks = await _getPersistedTasks(tasks, tx);
      await _toggleTree(newTasks.first, tx);

      if (parentId is int && await _isFocused(parentId, tx)) {
        await _unfocusByIds([parentId], tx);
        await _focus(newTasks, tx);
      }
    });
    return newTasks;
  }

  Future<int> _getChildLastPosition(int? parentId, SqliteReadContext tx) async {
    final lastPositionResult = await tx.get(
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

  Future<TaskList> _getPersistedTasks(
    TaskList tasks,
    SqliteReadContext tx,
  ) async {
    // TODO: Also make sure that NewTask generates uids using tests
    final uids = _uidsFromTasks(tasks);
    final newTasks = await _findTasksByUids(uids, tx);
    if (newTasks.length != uids.length) {
      throw Exception('Not all tasks were created.');
    }
    return newTasks;
  }

  List<String> _uidsFromTasks(TaskList tasks) {
    return tasks.map((task) => task.uid).toList();
  }

  Future<TaskList> _findTasksByUids(
    List<String> uids,
    SqliteReadContext tx,
  ) async {
    final questionMarks = _questionMarks(uids.length);
    final rows = await tx.getAll(
      '''
      SELECT * FROM tasks WHERE uid IN ($questionMarks) ORDER BY position
      ''',
      uids,
    );
    return rows.map(_taskFromRow).toList();
  }

  Future<Task> addTask(Task task, {int? position}) async {
    final newTasks = await addTasks([task], position: position);
    if (newTasks.isEmpty) {
      throw Exception('Task was not created.');
    }
    return newTasks.first;
  }

  Future<Task?> findTask(int id) => _findTask(id, db);

  Future<Task?> _findTask(int? id, SqliteReadContext tx) async {
    if (id == null) return null;
    final rows = await tx.getAll('SELECT * FROM tasks WHERE id = ?', [id]);
    return rows.isEmpty ? null : _taskFromRow(rows.first);
  }

  Future<Task?> findTaskByName(String name) async {
    final rows = await db.getAll('SELECT * FROM tasks WHERE UPPER(name) LIKE ?',
        ["%${name.toUpperCase()}%"]);
    return rows.isEmpty ? null : _taskFromRow(rows.first);
  }

  Future<Task> updateTask(Task task) async {
    if (task is ModifiedTask) {
      late Task? updatedTask;
      await db.writeTransaction((tx) async {
        await _updateTask(task, tx);
        await _toggleTreeIfToggled(task, tx);
        await _focusCheck(task, tx);
        updatedTask = await _findTask(task.id, tx);
      });
      if (updatedTask == null) {
        throw Exception('Task was not updated.');
      }
      return updatedTask!;
    } else {
      throw ArgumentError('Task must be a ModifiedTask');
    }
  }

  Future<void> _focusCheck(ModifiedTask task, SqliteWriteContext tx) async {
    if (task.hasToggledDone()) {
      if (task.done) {
        await _unfocus([task], tx);
      }
    }
  }

  // TODO: The interface does not evoke the intent of its usage
  /// _toggleTree toggles the doneAt field of its ancestors and descendants if
  /// applicable
  Future<void> _toggleTree(Task task, SqliteWriteContext tx,
      {DateTime? doneAt}) async {
    await _toggleAncestorsDone(task, tx, doneAt: doneAt);
    await _toggleDescendantsDone(task, tx, doneAt: doneAt);
  }

  Future<void> _toggleTreeIfToggled(ModifiedTask task, SqliteWriteContext tx,
      {DateTime? doneAt}) async {
    if (task.hasToggledDone()) {
      await _toggleTree(task, tx, doneAt: doneAt);
    }
  }

  // TODO: There must be a better way to do this using only a few queries
  Future<void> _toggleAncestorsDone(
    Task task,
    SqliteWriteContext tx, {
    DateTime? doneAt,
  }) async {
    final ancestors = await _ancestors(task, tx);
    final doneAtTrue = doneAt ?? task.doneAt;
    for (final ancestor in ancestors) {
      if (
          // ancestor is done and task is not done
          (doneAtTrue == null && ancestor.done) ||
              // ancestor is not done and all children are done
              (doneAtTrue != null && await _allChildrenDone(ancestor, tx))) {
        await _toggleDoneById(
          doneAtTrue?.millisecondsSinceEpoch,
          ancestor.id,
          tx,
        );
      }
    }
  }

  Future<void> _toggleDoneById(
    int? doneAtEpoch,
    int id,
    SqliteWriteContext tx,
  ) =>
      tx.execute(
        '''
          UPDATE tasks
          SET doneAt = ?
          WHERE id = ?
          ''',
        [doneAtEpoch, id],
      );

  Future<void> _toggleDescendantsDone(Task task, SqliteWriteContext tx,
      {DateTime? doneAt}) async {
    final descendants = await _descendants(task, tx);
    final doneAtTrue = doneAt ?? task.doneAt;
    for (final descendant in descendants) {
      await tx.execute(
        '''
        UPDATE tasks
        SET doneAt = ?
        WHERE id = ?
        ''',
        [doneAtTrue?.millisecondsSinceEpoch, descendant.id],
      );
    }
    if (doneAtTrue != null) {
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
    return rows.map(_taskFromRow).toList();
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
    return rows.map(_taskFromRow).toList();
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
      await tx.execute('DELETE FROM tasks WHERE id = ?', [task.id]);
      await _reorderChildren(tx, task.parentId);
      await _toggleTree(task, tx, doneAt: DateTime.now());
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

  Future<void> initialAreas(TaskList areas) async {
    final root = await findTask(1);
    if (root != null) {
      return;
    }
    await addTask(NewTask(name: 'Root', id: 1, uid: 'root', expanded: true));
    for (final area in areas) {
      await addTask(area.copyWith(parentId: 1));
    }
  }

  FutureOr<TaskList> getChildren(Task task) async {
    final rows = await db.getAll(
      'SELECT * FROM tasks WHERE parentId = ? ORDER BY position ASC',
      [task.id],
    );
    return rows.map(_taskFromRow).toList();
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
    return _leaves([task], db);
  }

  Future<TaskList> _leaves(
    TaskList tasks,
    SqliteReadContext tx, {
    bool? done,
  }) async {
    final ids = tasks.map(_getTaskId).toList();
    final rows = await tx.getAll(
      '''
        WITH RECURSIVE
          subtree(lvl, ${_commaFields(_allTaskFields)}) AS (
            SELECT
              0 AS lvl,
              ${_commaFields(_allTaskFields, prefix: 'tasks')}
            FROM tasks
            WHERE tasks.parentId IN (${_questionMarks(ids.length)})
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
        ${done is bool ? 'AND doneAt IS ${done ? 'NOT' : ''} NULL' : ''}
        ''',
      ids,
    );
    return rows.map(_taskFromRow).toList();
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
    return rows.map(_taskFromRow).toList();
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
      await _focus([task], tx, position: position);
    });
  }

  Future<void> _focus(
    TaskList tasks,
    SqliteWriteContext tx, {
    int position = 0,
  }) async {
    final taskLeaves = await _leaves(
      tasks,
      tx,
      done: false,
    );
    final toAdd = (taskLeaves.isEmpty ? tasks : taskLeaves).reversed.toList();

    await _unfocus(toAdd, tx);

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
        toAdd.mapIndexed((i, task) => [task.id, i + maxPosition]).toList(),
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
          final (index, task) = item;
          return [task.id, realPosition + index];
        }).toList(),
      );
    }
  }

  Future<bool> _isFocused(int? id, SqliteReadContext tx) async {
    if (id == null) return false;
    final result = await tx.get(
      'SELECT count(taskId) as count FROM focusQueue WHERE taskId = ?',
      [id],
    );
    return result['count'] as int > 0;
  }

  Future<void> unfocus(Task task) async {
    await _unfocus([task], db);
  }

  Future<void> _unfocus(TaskList tasks, SqliteWriteContext tx) =>
      _unfocusByIds(tasks.map(_getTaskId).toList(), tx);

  Future<void> _unfocusByIds(List<int> ids, SqliteWriteContext tx) async {
    await tx.execute(
      '''
      DELETE FROM focusQueue WHERE taskId IN (${_questionMarks(ids.length)})
      ''',
      ids,
    );
    await _normalizeFocusQueuePositions(tx);
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
  }
}
