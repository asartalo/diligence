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

import 'package:sqlite_async/sqlite3.dart';
import 'package:sqlite_async/sqlite_async.dart';

import '../../models/modified_task.dart';
import '../../models/new_task.dart';
import '../../models/persisted_task.dart';
import '../../models/reminders/reminder.dart';
import '../../models/reminders/reminder_list.dart';
import '../../models/task.dart';
import '../../models/task_list.dart';
import '../../models/task_node.dart';
import '../../models/task_pack.dart';
import '../../utils/clock.dart';
import '../../utils/date_time_from_row_epoch.dart';
import 'focus_queue_manager.dart';
import 'task_db.dart';
import 'task_events/added_reminders_event.dart';
import 'task_events/deleted_task_event.dart';
import 'task_events/removed_reminders_event.dart';
import 'task_events/task_event.dart';
import 'task_events/task_event_registry.dart';
import 'task_events/toggled_tasks_done_event.dart';
import 'task_events/updated_task_event.dart';
import 'task_fields.dart';
import '../migrate.dart';
import 'tasks_repository.dart';
import 'transactions/transaction_factory.dart';

typedef TaskNodeList = List<TaskNode>;

class Diligent extends TaskDb {
  @override
  final SqliteDatabase db;

  final FocusQueueManager focusQueueManager;

  final Clock clock;

  final bool _isTest;

  final TransactionFactory _transactionFactory;

  final TaskEventRegistry _eventRegistry;

  Diligent._internal({
    required this.db,
    required bool isTest,
    required this.focusQueueManager,
    required this.clock,
    required TaskEventRegistry eventRegistry,
    required TransactionFactory transactionFactory,
  }) : _isTest = isTest,
       _eventRegistry = eventRegistry,
       _transactionFactory = transactionFactory {
    focusQueueManager.registerEventHandlers(this);
  }

  factory Diligent.convenience({
    required bool isTest,
    required SqliteDatabase db,
    required TaskEventRegistry eventRegistry,
    required TransactionFactory transactionFactory,
    Clock? clock,
  }) {
    final actualClock = clock ?? Clock();

    return Diligent._internal(
      db: db,
      isTest: isTest,
      clock: actualClock,
      eventRegistry: eventRegistry,
      transactionFactory: transactionFactory,
      focusQueueManager: FocusQueueManager(db: db, clock: actualClock),
    );
  }

  factory Diligent({
    required SqliteDatabase db,
    Clock? clock,
    required TaskEventRegistry eventRegistry,
    required TransactionFactory transactionFactory,
  }) {
    return Diligent.convenience(
      isTest: false,
      db: db,
      clock: clock,
      eventRegistry: eventRegistry,
      transactionFactory: transactionFactory,
    );
  }

  Future<void> setUp() async {
    await db.execute('PRAGMA foreign_keys = ON');
    await migrations.migrate(db);
  }

  Future<void> clearDataForTests() async {
    if (_isTest) {
      await db.execute('DELETE FROM focusQueue');
      await db.execute('DELETE FROM reminders');
      await db.execute('DELETE FROM notices');
      await db.execute('DELETE FROM jobs');
      await db.execute('DELETE FROM tasks');
    }
  }

  void register<T extends TaskEvent>(TaskEventHandler<T> handler) {
    _eventRegistry.register(handler);
  }

  Future<void> announceEvent<T extends TaskEvent>(T event) async {
    await _eventRegistry.broadcast<T>(event);
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
    DateTime? now,
  }) => TasksRepository.newTask(
    id: id,
    parentId: parentId,
    parent: parent,
    doneAt: doneAt,
    uid: uid,
    name: name,
    details: details,
    expanded: expanded,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deadlineAt: deadlineAt,
    now: now ?? clock.now(),
  );

  Future<TaskList> addTasks(TaskList tasks, {int? position}) async {
    TaskList newTasks = [];

    await db.writeTransaction((tx) async {
      newTasks = await _transactionFactory
          .addTasks(tx)
          .work(tasks, position: position);
    });

    return newTasks;
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

      await announceEvent(
        UpdatedTaskEvent(
          clock.now(),
          modified: task,
          persisted: updatedTask as PersistedTask,
          tx: tx,
        ),
      );
    });

    return updatedTask!;
  }

  Future<void> _toggleLineage(
    Task task,
    SqliteWriteContext tx, {
    bool forceDescendants = false,
    bool startAtTask = false,
  }) async {
    await _toggleAncestorsDone(task, tx, startAtTask: startAtTask);
    if (forceDescendants) {
      await _toggleDescendantsDone(task, tx);
    }
  }

  Future<void> _toggleTreeIfToggled(
    ModifiedTask task,
    SqliteWriteContext tx,
  ) async {
    if (task.hasToggledDone()) {
      await _toggleLineage(task, tx, forceDescendants: true);
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
        await _toggleDoneById(doneAt?.millisecondsSinceEpoch, ancestor.id, tx);
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
      tx.execute('UPDATE tasks SET doneAt = ? WHERE id = ?', [doneAtEpoch, id]);

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
    announceEvent(
      ToggledTasksDoneEvent(
        clock.now(),
        tasks: descendants,
        tx: tx,
        doneAt: doneAt,
      ),
    );
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
    final doneAtEpoch = result['latestDoneAt'] == null
        ? 0
        : result['latestDoneAt'] as int;
    final doneAt = doneAtEpoch > 0 ? dateTimeFromRowEpoch(doneAtEpoch) : null;

    return count == doneCount ? doneAt : null;
  }

  Future<TaskList> ancestors(Task task) => _ancestors(task, db, reverse: true);

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
    Task task,
    SqliteWriteContext tx, {
    bool includeTaskAsAncestor = false,
    bool reverse = false,
  }) async {
    final id = includeTaskAsAncestor ? task.id : task.parentId;
    final rows = await tx.getAll(
      reverse ? _ancestorsQueryReverse : _ancestorsQuery,
      [id],
    );

    return rows.map(taskFromRow).toList();
  }

  Future<TaskList> descendants(Task task) => _descendants(task, db);

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

    return rows.map(taskFromRow).toList();
  }

  Future<void> _updateTask(ModifiedTask task, SqliteWriteContext tx) async {
    await tx.execute(
      '''
      UPDATE tasks
      SET ${fieldValuePlaceholders(modifiableNonPositionFields)}
      WHERE id = ?
      ''',
      [...propsFromTaskFields(modifiableNonPositionFields, task), task.id],
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
        await _toggleLineage(task, tx);
      }
    });

    await announceEvent(DeletedTaskEvent(clock.now(), task: task));
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

      await _toggleLineage(parent, tx, startAtTask: true);
      await _reorderChildren(tx, task.parentId);
      final oldParent = await _findTask(task.parentId, tx);
      if (oldParent is Task) {
        await _toggleLineage(oldParent, tx, startAtTask: true);
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
      await addTask(
        area.copyWith(parentId: 1, updatedAt: now, createdAt: now, now: now),
      );
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
    final rows = await db.getAll('SELECT * FROM tasks WHERE id = ?', [
      task.parentId,
    ]);

    return rows.isEmpty ? null : taskFromRow(rows.first);
  }

  /// Returns a task and its descendants as an ordered list
  Future<TaskNodeList> subtreeFlat(int id) async {
    final rows = await db.getAll(
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
    final rows = await db.getAll(
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

  Future<TaskList> leaves(Task task) {
    return leavesInContext([task], db);
  }

  Future<TaskList> focusQueue({int? limit}) =>
      focusQueueManager.focusQueue(limit: limit);

  Future<int> getFocusedCount() => focusQueueManager.getFocusedCount();

  Future<void> focus(Task task, {int position = 0}) =>
      focusQueueManager.focus(task, position: position);

  Future<void> focusTasks(TaskList tasks, {int position = 0}) =>
      focusQueueManager.focusTasks(tasks, position: position);

  Future<void> unfocus(Task task) => focusQueueManager.unfocus(task);

  Future<void> reprioritizeInFocusQueue(Task task, int position) =>
      focusQueueManager.reprioritizeInFocusQueue(task, position);

  Future<void> addReminders(List<Reminder> reminders) async {
    await db.writeTransaction((tx) async {
      final batchProps = reminders.map((reminder) {
        return [reminder.taskId, reminder.remindAt.millisecondsSinceEpoch];
      }).toList();

      await tx.executeBatch(
        'INSERT INTO reminders (taskId, remindAt) VALUES (?, ?)',
        batchProps,
      );
    });
    await announceEvent(AddedRemindersEvent(clock.now(), reminders: reminders));
  }

  Future<ReminderList> getNextReminders(DateTime now) async {
    final rows = await db.getAll(
      '''
      SELECT reminders.*
      FROM reminders
      WHERE reminders.remindAt <= ?
      ORDER BY reminders.remindAt ASC
      ''',
      [now.millisecondsSinceEpoch],
    );

    return ReminderList(rows.map(reminderFromRow).toList());
  }

  Future<ReminderList> getRemindersForTask(Task task) async {
    return getRemindersForTaskIds([task.id]);
  }

  Future<ReminderList> getRemindersForTaskIds(List<int> taskIds) async {
    final rows = await db.getAll('''
      SELECT reminders.*
      FROM reminders
      WHERE reminders.taskId IN (${questionMarks(taskIds.length)})
      ORDER BY reminders.remindAt ASC
      ''', taskIds);

    return ReminderList(rows.map(reminderFromRow).toList());
  }

  Future<Reminder> dismissReminder(Reminder reminder) async {
    if (clock.now().isBefore(reminder.remindAt)) {
      throw ReminderError('Cannot dismiss a reminder before it is due.');
    }

    final Reminder(:taskId, :remindAt) = reminder;
    await db.execute(
      '''
      UPDATE reminders
      SET dismissed = 1
      WHERE taskId = ? AND remindAt = ?
      ''',
      [taskId, remindAt.millisecondsSinceEpoch],
    );

    return reminder.dismiss();
  }

  Future<void> deleteReminders(List<Reminder> reminders) async {
    await db.executeBatch(
      '''
      DELETE FROM reminders
      WHERE taskId = ? AND remindAt = ?
      ''',
      reminders.map((reminder) {
        return [reminder.taskId, reminder.remindAt.millisecondsSinceEpoch];
      }).toList(),
    );
    await announceEvent(
      RemovedRemindersEvent(clock.now(), reminders: reminders),
    );
  }

  Reminder reminderFromRow(Row row) {
    return Reminder(
      taskId: row['taskId'] as int,
      remindAt: dateTimeFromRowEpoch(row['remindAt']),
      dismissed: row['dismissed'] as int == 1,
    );
  }

  Future<TaskPack?> getTaskPackById(int id) async {
    final task = await findTask(id);

    if (task == null) {
      return null;
    }

    return TaskPack(task, reminders: await getRemindersForTask(task));
  }
}

class ReminderError extends Error {
  final String message;

  ReminderError(this.message);

  @override
  String toString() => 'ReminderError: $message';
}
