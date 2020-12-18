import 'dart:io';

import 'package:sqflite/sqflite.dart';

class SqliteSchema {
  final Database db;

  SqliteSchema(this.db);

  /// Loads an sql file to the database
  Future<void> loadSqlFile(String filePath) async {
    final file = File(filePath);
    await db.execute(await file.readAsString());
  }

  Future<void> dumpSchemaToFile(String filePath) async {
    final file = File(filePath);
    final schemas =
        await db.rawQuery('SELECT sql FROM sqlite_master ORDER BY name;');
    for (final row in schemas) {
      await file.writeAsString("\n${row['sql']}", mode: FileMode.append);
    }
  }
}
