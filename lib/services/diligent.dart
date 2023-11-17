import 'dart:async';
import 'package:sqlite_async/sqlite3.dart';
import 'package:sqlite_async/sqlite_async.dart';
import '../model/provided_task.dart';
import '../model/task.dart';

typedef VoidCallback = void Function();
typedef TaskList = List<Task>;

final migrations = SqliteMigrations()
  ..add(SqliteMigration(1, (tx) async {
    await tx.execute('''
      CREATE TABLE IF NOT EXISTS tasks (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        parentId INTEGER,
        done INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }));

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

  Future<Task?> addTask(Task task) async {
    await db.execute(
      'INSERT INTO tasks (name, parentId) VALUES (?, ?)',
      [task.name, task.parentId],
    );
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

  Future<void> updateTask(Task task) async {
    await db.execute(
      'UPDATE tasks SET name = ?, parentId = ?, done = ? WHERE id = ?',
      [task.name, task.parentId, if (task.done) 1 else 0, task.id],
    );
  }

  Task _taskFromRow(Row row) {
    return ProvidedTask(
      id: row['id'] as int,
      name: row['name'] as String,
      parentId: row['parentId'] as int?,
      done: row['done'] as int == 1,
      nodeProvider: this,
    );
  }

  Future<void> deleteTask(Task task) async {
    await db.execute('DELETE FROM tasks WHERE id = ?', [task.id]);
  }

  @override
  FutureOr<List<Task>> getChildren(Task task) async {
    final rows =
        await db.getAll('SELECT * FROM tasks WHERE parentId = ?', [task.id]);
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
