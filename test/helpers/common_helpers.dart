import 'dart:io';

import 'package:diligence/model/task.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';

const Map<String, int> taskIds = {
  // Roots
  'Root': 1,
  'Orphans': 3207,
  'Trash': 3227,
  'Templates': 3210,
  // Root children
  'Life Goals': 2,
  'Work': 364,
  'Projects': 2252,
  'Everyday': 3154,
};

class TestDbFile {
  final String name;
  String _path;

  TestDbFile(this.name);

  String get path {
    if (_path == null) {
      _path = join(
        Directory.systemTemp.path,
        name,
      );
    }
    return _path;
  }

  setUp() async {
    final dbFile = File(path);
    if (await dbFile.exists()) {
      await dbFile.delete();
    }
  }
}

Future<void> createTask(Database db, TaskRow row) async {
  await db.insert('tasks', row.toSqliteMap());
}
