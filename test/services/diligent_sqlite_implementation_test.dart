import 'package:diligence/models/tasks.dart';
import 'package:diligence/services/diligent.dart';
import 'package:diligence/utils/stub_clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_async/sqlite_async.dart';

import 'diligent_test.dart';

void main() {
  // The following tests are implementation details specific to using SQLite
  // version of Diligent. We should prioritize making diligent_test.dart pass
  //first before making this implementation test pass.
  group('Diligent SQLite Implementation', () {
    late Diligent diligent;
    late StubClock clock;
    late Map<String, Task> setupResult;

    setUpAll(() async {
      clock = StubClock();
      diligent = Diligent.forTests(
        db: SqliteDatabase(path: 'diligent_sqlite_implementation_test.db'),
        clock: clock,
      );
      await diligent.setUp();
    });

    tearDown(() async {
      await diligent.clearDataForTests();
    });

    setUp(() async {
      setupResult = await testTreeSetup(diligent);
    });

    test(
      "when a task is deleted, it's id is removed from focusQueue table",
      () async {
        final task = setupResult['A1i - leaf']!;
        await diligent.focus(task);
        await diligent.deleteTask(task);
        final rows = await diligent.db.getAll(
          '''SELECT * FROM focusQueue WHERE taskId = ?''',
          [task.id],
        );

        expect(rows.length, equals(0));
      },
    );
  });
}
