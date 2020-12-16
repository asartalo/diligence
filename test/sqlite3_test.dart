import 'dart:io';

import 'package:diligence/constants.dart';
import 'package:diligence/utils/sqflite_prepare.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import 'helpers/common_helpers.dart';

void main() async {
  Database db;
  ProjectPaths paths = ProjectPaths.instance;

  sqflitePrepare();

  TestDbFile dbFile = TestDbFile('test_database.db');

  tearDownAll(() async {
    if (db != null) {
      await db.close();
      await deleteDatabase(dbFile.path);
    }
  });

  group('Testing with own file database', () {
    setUp(() async {
      dbFile.setUp();
      db = await openDatabase(dbFile.path);
      final file = File(path.join(paths.testPath, 'fixtures/test.sql'));
      final contents = await file.readAsString();
      await db.execute(contents);
    });

    test('it loads data', () async {
      var result =
          await db.rawQuery('SELECT * FROM tasks WHERE old_id = "0" LIMIT 1;');
      expect(result.first['name'], 'Root');
    });
  });
}
