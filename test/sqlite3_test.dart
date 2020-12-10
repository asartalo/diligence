import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  Database db;
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  String dbPath = path.join(await getDatabasesPath(), 'test_database.db');

  tearDownAll(() async {
    if (db != null) {
      await db.close();
      await deleteDatabase(dbPath);
    }
  });

  group('Testing with own file database', () {
    setUp(() async {
      db = await openDatabase(dbPath);
      final file = File('test/fixtures/test.sql');
      final contents = await file.readAsString();
      // Load data:
      await db.execute(contents);
    });

    test('it loads data', () async {
      var result =
          await db.rawQuery('SELECT * FROM tasks WHERE old_id = "0" LIMIT 1;');
      expect(result.first['name'], 'Root');
    });
  });
}
