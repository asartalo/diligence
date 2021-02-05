import 'package:diligence/constants.dart';
import 'package:diligence/services/review_data_service/summary_task_cache.dart';
import 'package:diligence/services/sqlite_schema.dart';
import 'package:diligence/utils/sqflite_prepare.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../../helpers/common_helpers.dart';
import '../../helpers/database_log_wrapper.dart';

void main() {
  group('SummaryTaskCache', () {
    late DatabaseLogWrapper db;
    late SummaryTaskCache cache;
    final paths = ProjectPaths.instance;
    sqflitePrepare();
    final dbFile = TestDbFile('test_database.db');

    setUp(() async {
      await dbFile.setUp();
      db = DatabaseLogWrapper(await openDatabase(dbFile.path));
      await SqliteSchema(db).loadSqlFile(path.join(
        paths.test,
        'fixtures/test.sql',
      ));
      cache = SummaryTaskCache(db);
    });

    tearDown(() async {
      if (db is Database) {
        await db.close();
      }
    });

    group('getAll()', () {
      late List<String> result;

      setUp(() async {
        result = await cache.getAll([
          taskIds['Life Goals']!,
          taskIds['Work']!,
          8713491234, // this does not exist
          taskIds['Projects']!,
        ]);
      });

      test('it retrieves task names based on ids', () {
        expect(result, equals(['Life Goals', 'Work', '', 'Projects']));
      });

      test('it calls rawQuery once', () {
        expect(db.getMethodLog('rawQuery').count, equals(1));
      });

      group('when it is called with same ids', () {
        setUp(() async {
          result = await cache.getAll([
            taskIds['Work']!,
            taskIds['Life Goals']!,
            taskIds['Projects']!,
          ]);
        });

        test('it retrieves task names based on ids', () {
          expect(result, equals(['Work', 'Life Goals', 'Projects']));
        });

        test('it does not query names if it retrieved them already', () async {
          expect(db.getMethodLog('rawQuery').count, equals(1));
        });
      });
    });

    group('get()', () {
      test('it retrieves the name based on id', () async {
        final name = await cache.get(taskIds['Projects']!);
        expect(name, equals('Projects'));
      });
    });
  });
}
