import 'package:diligence/constants.dart';
import 'package:diligence/services/review_data_service/summary_task_cache.dart';
import 'package:diligence/services/sqlite_schema.dart';
import 'package:diligence/utils/sqflite_prepare.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../../helpers/common_helpers.dart';

void main() {
  group('basic integration', () {
    Database db;
    SummaryTaskCache cache;
    final paths = ProjectPaths.instance;
    sqflitePrepare();
    final dbFile = TestDbFile('test_database.db');

    setUp(() async {
      await dbFile.setUp();
      db = await openDatabase(dbFile.path);
      await SqliteSchema(db).loadSqlFile(path.join(
        paths.test,
        'fixtures/test.sql',
      ));
      cache = SummaryTaskCache(db);
    });

    tearDown(() async {
      if (db != null) {
        await db.close();
      }
    });

    test('it retrieves task names based on ids', () async {
      final result = await cache.getAll([
        taskIds['Life Goals'],
        taskIds['Work'],
        taskIds['Projects'],
      ]);
      expect(result, equals([2, 364, 2252, 3154]));
    });
  });
}
