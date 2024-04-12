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
import 'dart:math';

import 'package:clock/clock.dart' as dc;
import 'package:collection/collection.dart';
import 'package:sqlite_async/sqlite3.dart';
import 'package:sqlite_async/sqlite_async.dart';

import '../models/modified_task.dart';
import '../models/new_task.dart';
import '../models/persisted_task.dart';
import '../models/task.dart';
import '../models/task_list.dart';
import '../models/task_node.dart';
import 'diligent/focus_queue_manager.dart';
import 'diligent/task_db.dart';
import 'diligent/task_events/added_tasks_event.dart';
import 'diligent/task_events/task_event.dart';
import 'diligent/task_events/task_event_registry.dart';
import 'diligent/task_events/toggled_tasks_done_event.dart';
import 'diligent/task_events/updated_task_event.dart';
import 'diligent/task_fields.dart';
import 'migrations.dart';

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

const _testDbPath = 'test.db';
const _defaultDbPath = 'diligence.db';

class Diligent extends TaskDb {
  @override
  final SqliteDatabase db;

  final FocusQueueManager focusQueueManager;

  final String path;

  final dc.Clock clock;

  final bool _isTest;

  final TaskEventRegistry _eventRegistry = TaskEventRegistry();

  Diligent._internal({
    required this.db,
    required this.path,
    required bool isTest,
    required this.focusQueueManager,
    required this.clock,
  }) : _isTest = isTest {
    focusQueueManager.registerEventHandlers(this);
  }

  factory Diligent({String path = _defaultDbPath, dc.Clock? clock}) {
    final db = SqliteDatabase(path: path);
    final actualClock = clock ?? const dc.Clock();

    return Diligent._internal(
      db: db,
      path: path,
      isTest: false,
      clock: actualClock,
      focusQueueManager: FocusQueueManager(db: db, clock: actualClock),
    );
  }

  factory Diligent.forTests({dc.Clock? clock}) {
    final db = SqliteDatabase(path: _testDbPath);
    final actualClock = clock ?? const dc.Clock();

    return Diligent._internal(
      path: _testDbPath,
      db: db,
      isTest: true,
      clock: actualClock,
      focusQueueManager: FocusQueueManager(db: db, clock: actualClock),
    );
  }

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

  void register<T extends TaskEvent>(TaskEventHandler<T> handler) {
    _eventRegistry.register(handler);
  }

  Future<void> announceEvent<T extends TaskEvent>(T event) async {
    await _eventRegistry.broadcast<T>(event);
  }

  Future<void> _validateAddedTasks(
    TaskList tasks,
    SqliteReadContext tx,
  ) async {
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
      final parent = await _findTask(parentId, tx);
      if (parent == null) {
        throw ArgumentError('Parent with id $parentId does not exist.');
      }
    }
  }

  NewTask newTask({
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
      createdAt: createdAt ?? clock.now(),
      updatedAt: updatedAt ?? clock.now(),
      deadlineAt: deadlineAt,
    );
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
          ...propsFromTaskFields(newTaskFields, task),
          positionToUse + index,
        ];
      }).toList();
      await tx.executeBatch(
        _cachedQuery(
          'tasksInsertWithPosition',
          '''
          INSERT INTO tasks (${newTaskFields.join(', ')}, position)
          SELECT ${questionMarks(newTaskFields.length + 1)}
          ''',
        ),
        batchProps,
      );

      newTasks = await _getPersistedTasks(tasks, tx);
      await _toggleSubtree(newTasks.first, tx);

      await announceEvent(AddedTasksEvent(
        clock.now(),
        tx: tx,
        parentId: parentId,
        tasks: newTasks,
      ));
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
    final qMarks = questionMarks(uids.length);
    final rows = await tx.getAll(
      '''
      SELECT * FROM tasks WHERE uid IN ($qMarks) ORDER BY position
      ''',
      uids,
    );

    return rows.map(taskFromRow).toList();
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

    return rows.isEmpty ? null : taskFromRow(rows.first);
  }

  Future<Task?> findTaskByName(String name) async {
    final rows = await db.getAll(
      'SELECT * FROM tasks WHERE UPPER(name) LIKE ?',
      ["%${name.toUpperCase()}%"],
    );

    return rows.isEmpty ? null : taskFromRow(rows.first);
  }

  Future<Task> updateTask(Task task) async {
    if (task is! ModifiedTask) {
      throw ArgumentError('Task must be a ModifiedTask');
    }

    late Task? updatedTask;
    await db.writeTransaction((tx) async {
      await _updateTask(task, tx);
      await _toggleTreeIfToggled(task, tx);
      updatedTask = await _findTask(task.id, tx);
      if (updatedTask == null) {
        throw Exception('Task was not updated.');
      }

      await announceEvent(UpdatedTaskEvent(
        clock.now(),
        modified: task,
        persisted: updatedTask as PersistedTask,
        tx: tx,
      ));
    });

    return updatedTask!;
  }

  // TODO: The interface does not evoke the intent of its usage
  /// _toggleTree toggles the doneAt field of its ancestors and descendants if
  /// applicable
  Future<void> _toggleSubtree(
    Task task,
    SqliteWriteContext tx, {
    bool forceDescendants = false,
    bool startAtTask = false,
  }) async {
    await _toggleAncestorsDone(
      task,
      tx,
      startAtTask: startAtTask,
    );
    if (forceDescendants) {
      await _toggleDescendantsDone(task, tx);
    }
  }

  Future<void> _toggleTreeIfToggled(
    ModifiedTask task,
    SqliteWriteContext tx,
  ) async {
    if (task.hasToggledDone()) {
      await _toggleSubtree(task, tx, forceDescendants: true);
    }
  }

  // TODO: There must be a better way to do this using only a few queries
  Future<void> _toggleAncestorsDone(
    Task task,
    SqliteWriteContext tx, {
    bool startAtTask = false,
  }) async {
    final ancestors = await _ancestors(
      task,
      tx,
      includeTaskAsAncestor: startAtTask,
    );
    for (final ancestor in ancestors) {
      final doneAt = await _allChildrenDone(ancestor, tx);
      if (
          // ancestor is done and task is not done
          (doneAt == null && ancestor.done) ||
              // ancestor is not done and all children are done
              (doneAt is DateTime &&
                  (doneAt.millisecondsSinceEpoch !=
                      ancestor.doneAt?.millisecondsSinceEpoch))) {
        await _toggleDoneById(
          doneAt?.millisecondsSinceEpoch,
          ancestor.id,
          tx,
        );
      } else {
        break;
      }
    }
  }

  Future<void> _toggleDoneById(
    int? doneAtEpoch,
    int id,
    SqliteWriteContext tx,
  ) =>
      tx.execute(
        'UPDATE tasks SET doneAt = ? WHERE id = ?',
        [doneAtEpoch, id],
      );

  Future<void> _toggleDescendantsDone(Task task, SqliteWriteContext tx) async {
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
    announceEvent(ToggledTasksDoneEvent(
      clock.now(),
      tasks: descendants,
      tx: tx,
      doneAt: doneAt,
    ));
  }

  Future<DateTime?> _allChildrenDone(Task task, SqliteReadContext tx) async {
    final result = await tx.get(
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
    final doneAtEpoch =
        result['latestDoneAt'] == null ? 0 : result['latestDoneAt'] as int;
    final doneAt = doneAtEpoch > 0
        ? DateTime.fromMillisecondsSinceEpoch(doneAtEpoch)
        : null;

    return count == doneCount ? doneAt : null;
  }

  Future<TaskList> ancestors(Task task) => _ancestors(task, db);

  Future<TaskList> _ancestors(
    Task task,
    SqliteWriteContext tx, {
    bool includeTaskAsAncestor = false,
  }) async {
    final id = includeTaskAsAncestor ? task.id : task.parentId;
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
      [id],
    );

    return rows.map(taskFromRow).toList();
  }

  Future<TaskList> descendants(Task task) => _descendants(task, db);

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

    return rows.map(taskFromRow).toList();
  }

  Future<void> _updateTask(ModifiedTask task, SqliteWriteContext tx) async {
    await tx.execute(
      _cachedQuery(
        'updateTask',
        '''
          UPDATE tasks
          SET ${fieldValuePlaceholders(modifiableNonPositionFields)}
          WHERE id = ?
        ''',
      ),
      [
        ...propsFromTaskFields(
          modifiableNonPositionFields,
          task,
        ),
        task.id,
      ],
    );
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

  Future<void> deleteTask(Task task) async {
    await db.writeTransaction((tx) async {
      await tx.execute('DELETE FROM tasks WHERE id = ?', [task.id]);
      await _reorderChildren(tx, task.parentId);
      final parent = await _findTask(task.parentId, tx);
      if (parent is Task) {
        await _toggleSubtree(task, tx);
      }
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
    if (parent is Task && parent.id != task.parentId) {
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

      await _toggleSubtree(parent, tx, startAtTask: true);
      await _reorderChildren(tx, task.parentId);
      final oldParent = await _findTask(task.parentId, tx);
      if (oldParent is Task) {
        await _toggleSubtree(oldParent, tx, startAtTask: true);
      }
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
    Task task,
    SqliteReadContext tx,
  ) async {
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

    await addTask(newTask(name: 'Root', id: 1, uid: 'root', expanded: true));
    final now = clock.now();
    for (final area in areas) {
      await addTask(area.copyWith(
        parentId: 1,
        updatedAt: now,
        createdAt: now,
      ));
    }
  }

  FutureOr<TaskList> getChildren(Task task) async {
    final rows = await db.getAll(
      'SELECT * FROM tasks WHERE parentId = ? ORDER BY position ASC',
      [task.id],
    );

    return rows.map(taskFromRow).toList();
  }

  FutureOr<Task?> getParent(Task task) async {
    if (task.parentId == null) return null;
    final rows = await db.getAll(
      'SELECT * FROM tasks WHERE id = ?',
      [task.parentId],
    );

    return rows.isEmpty ? null : taskFromRow(rows.first);
  }

  /// Returns a task and its descendants as an ordered list
  Future<TaskNodeList> subtreeFlat(int id) async {
    final rows = await db.getAll(
      _cachedQuery(
        'subtreeFlat',
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
    return leavesInContext([task], db);
  }

  Future<TaskList> focusQueue({int? limit}) =>
      focusQueueManager.focusQueue(limit: limit);

  Future<int> getFocusedCount() => focusQueueManager.getFocusedCount();

  Future<void> focus(Task task, {int position = 0}) => focusQueueManager.focus(
        task,
        position: position,
      );

  Future<void> focusTasks(TaskList tasks, {int position = 0}) =>
      focusQueueManager.focusTasks(
        tasks,
        position: position,
      );

  Future<void> unfocus(Task task) => focusQueueManager.unfocus(task);

  Future<void> reprioritizeInFocusQueue(Task task, int position) =>
      focusQueueManager.reprioritizeInFocusQueue(
        task,
        position,
      );
}
