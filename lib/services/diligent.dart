import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';
import 'package:sqlite_async/sqlite3.dart';
import 'package:sqlite_async/sqlite_async.dart';
import '../models/new_task.dart';
import '../models/provided_task.dart';
import '../models/task.dart';
import 'migrations.dart';

typedef VoidCallback = void Function();
typedef TaskList = List<Task>;

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

class Diligent implements NodeProvider {
  final SqliteDatabase db;
  final bool _isTest;

  Diligent({path = 'diligence.db'})
      : db = SqliteDatabase(path: path),
        _isTest = false;

  Diligent.forTests()
      : db = SqliteDatabase(path: 'test.db'),
        _isTest = true;

  Future<void> runMigrations() async => migrations.migrate(db);

  Future<void> clearDataForTests() async {
    if (_isTest) db.execute('DELETE FROM tasks');
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
          '''
          INSERT INTO tasks (name, parentId, details, position)
          SELECT ?, ?, ?, ?
          ''',
          [task.name, task.parentId, task.details, position],
        );
      });
    } else {
      await db.execute(
        '''
        INSERT INTO tasks (name, parentId, details, position)
        SELECT ?, ?, ?, COALESCE(MAX(position) + 1, 0) FROM tasks WHERE parentId = ?
        ''',
        [task.name, task.parentId, task.details, task.parentId],
      );
    }
    final result = await db.execute('SELECT last_insert_rowid() as id');
    return _asProvidedTask(task.copyWith(id: result.first['id'] as int));
  }

  Task _asProvidedTask(Task task) {
    if (task is ProvidedTask) return task;
    return ProvidedTask(
      id: task.id,
      name: task.name,
      parentId: task.parentId,
      done: task.done,
      nodeProvider: this,
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
    await db.execute(
      'UPDATE tasks SET name = ?, done = ? WHERE id = ?',
      [task.name, if (task.done) 1 else 0, task.id],
    );
  }

  Task _taskFromRow(Row row) {
    return ProvidedTask(
      id: row['id'] as int,
      name: row['name'] as String,
      parentId: row['parentId'] as int?,
      done: row['done'] as int == 1,
      details: row['details'] as String?,
      nodeProvider: this,
    );
  }

  Future<void> deleteTask(Task task) async {
    await db.execute('DELETE FROM tasks WHERE id = ?', [task.id]);
  }

  Future<void> moveTask(Task task, int position) async {
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
    await addTask(NewTask(name: 'Root', id: 1));
    for (final area in areas) {
      await addTask(area.copyWith(parentId: 1));
    }
  }

  @override
  FutureOr<List<Task>> getChildren(Task task) async {
    final rows = await db.getAll(
        'SELECT * FROM tasks WHERE parentId = ? ORDER BY position ASC',
        [task.id]);
    return rows.map((row) => _taskFromRow(row)).toList();
  }

  @override
  FutureOr<Task?> getParent(Task task) async {
    if (task.parentId == null) return null;
    final rows =
        await db.getAll('SELECT * FROM tasks WHERE id = ?', [task.parentId]);
    return rows.isEmpty ? null : _taskFromRow(rows.first);
  }

  /// Returns a task and its descendants as an ordered list
  Future<TaskList> subtreeFlat(int id) async {
    final rows = await db.getAll('''
      WITH RECURSIVE
        children_of(parent) AS (
          VALUES(?)
          UNION ALL
          SELECT id FROM tasks, children_of
          WHERE tasks.parentId=children_of.parent
        )
      SELECT * FROM tasks
      WHERE tasks.id IN children_of;;
    ''', [id]);
    return rows.map((row) => _taskFromRow(row)).toList();
  }
}
