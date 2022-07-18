import 'dart:io';

import 'package:diligence/services/sqlite_schema.dart';
import 'package:diligence/utils/sqflite_prepare.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

Future<void> main() async {
  late Database db;
  late SqliteSchema helper;

  sqflitePrepare();

  const sqlCreateString =
      'CREATE TABLE IF NOT EXISTS "settings" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "start_of_day" varchar);';
  setUp(() async {
    db = await openDatabase(inMemoryDatabasePath);
    helper = SqliteSchema(db);
  });

  tearDownAll(() {
    db.close();
  });

  group('SqliteSchema#loadSqlFile', () {
    late File schemaFile;

    setUp(() async {
      schemaFile = File(path.join(
        Directory.systemTemp.path,
        'schema_file.sql',
      ));
      await schemaFile.writeAsString(sqlCreateString);
      await helper.loadSqlFile(schemaFile.path);
    });

    tearDown(() async {
      await schemaFile.delete();
    });

    test('it loads schema', () async {
      final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='settings'",
      );
      expect(result.length, 1);
    });
  });

  group('SqliteSchema#dumpSchemaToFile', () {
    final sqlDumpPath = path.join(Directory.systemTemp.path, 'dump.sql');
    setUp(() async {
      await db.rawQuery(sqlCreateString);
      await helper.dumpSchemaToFile(sqlDumpPath);
    });

    test('writes to dump file', () async {
      expect(await File(sqlDumpPath).exists(), true);
    });

    test('writes sql dump content of database', () async {
      final contents = await File(sqlDumpPath).readAsString();
      expect(contents, contains('CREATE TABLE'));
      expect(contents, contains('settings'));
    });
  });
}
