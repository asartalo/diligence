import 'package:diligence/constants.dart';
import 'package:diligence/model/task.dart';
import 'package:diligence/services/review_data_service.dart';
import 'package:diligence/services/sqlite_schema.dart';
import 'package:diligence/utils/sqflite_prepare.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../helpers/common_helpers.dart';

main() async {
  Database db;
  ProjectPaths paths = ProjectPaths.instance;
  ReviewDataService service;
  sqflitePrepare();
  TestDbFile dbFile = TestDbFile('test_database.db');

  setUp(() async {
    await dbFile.setUp();
    db = await openDatabase(dbFile.path);
    await SqliteSchema(db).loadSqlFile(path.join(
      paths.testPath,
      'fixtures/test.sql',
    ));
    service = ReviewDataService(db);
  });

  tearDown(() async {
    if (db != null) {
      await db.close();
    }
  });

  test('it loads data', () async {
    var result =
        await db.rawQuery('SELECT * FROM tasks WHERE old_id = "0" LIMIT 1;');
    expect(result.first['name'], 'Root');
  });

  group('getSummaryData', () {
    ReviewSummaryData summary;

    setUp(() async {
      var now = DateTime.parse('2020-12-12 09:00:00');
      print(now.toString());
      await createTask(
          db,
          TaskRow(
            name: 'Foo',
            parentId: taskIds['Root'],
            sortOrder: 4,
            createdAt: now,
            updatedAt: now,
          ));
      summary = await service.getSummaryData(now);
    });

    test('contains completed count', () {
      expect(summary.newlyCreated, 1);
    });
  });
}
