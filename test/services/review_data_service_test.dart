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

    group('newlyCreated', () {
      setUp(() async {
        var now = DateTime.parse('2020-12-12 09:00:00');
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

    group('overdue and completed', () {
      setUp(() async {
        var now = DateTime.parse('2020-12-12 09:00:00');
        // Create Tasks...
        var parentId = taskIds['Life Goals'];
        var result = await db.rawQuery('''
            SELECT COUNT("tasks"."id") AS task_count 
            FROM tasks 
            WHERE parent_id = ?;
            ''', [parentId]);
        var childCount = result.first['task_count'];
        List<TaskRow> tasks = [
          TaskRow(
            name: 'Foo',
            parentId: parentId,
            sortOrder: childCount,
            createdAt: now,
            updatedAt: now,
            done: true,
            doneAt: now.subtract(Duration(days: 1)),
          ),
          TaskRow(
            name: 'Bar',
            parentId: parentId,
            sortOrder: childCount + 1,
            createdAt: now,
            updatedAt: now,
            done: true,
            doneAt: now,
          ),
          TaskRow(
            name: 'Car',
            parentId: parentId,
            sortOrder: childCount + 1,
            createdAt: now,
            updatedAt: now,
            done: true,
            doneAt: now,
          ),
        ];
        List<int> createdTaskIds = [];
        for (TaskRow row in tasks) {
          createdTaskIds.add(await createTask(db, row));
        }

        // Create Task Defers...
        final List<TaskDeferRow> taskDefers = [
          TaskDeferRow(taskId: createdTaskIds[1], duration: 60.0 * 10.0),
          TaskDeferRow(taskId: createdTaskIds[2], duration: 60.0 * 21.0),
          TaskDeferRow(taskId: createdTaskIds[2], duration: 60.0 * 11.0),
          TaskDeferRow(taskId: createdTaskIds[2], duration: 60.0 * 14.0),
        ];
        for (TaskDeferRow row in taskDefers) {
          await createTaskDefers(db, row);
        }
        summary = await service.getSummaryData(now);
      });

      test('contains overdue count', () {
        expect(summary.overdue, 1);
      });

      test('contains completed count', () {
        expect(summary.completed, 2);
      });
    });
  });
}
