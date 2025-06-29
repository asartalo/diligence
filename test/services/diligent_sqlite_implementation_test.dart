// Diligence - A Task Management App
//
// Copyright (C) 2024 Wayne Duran <asartalo@gmail.com>
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// this program. If not, see <https://www.gnu.org/licenses/>.

import 'package:diligence/models/tasks.dart';
import 'package:diligence/services/diligent/diligent.dart';
import 'package:diligence/services/diligent/diligent_factory.dart';
import 'package:diligence/utils/stub_clock.dart';
import 'package:flutter_test/flutter_test.dart';

import 'diligent/diligent_test.dart';

void main() {
  // The following tests are implementation details specific to using SQLite
  // version of Diligent. We should prioritize making diligent_test.dart pass
  // first before making this implementation test pass.
  //
  // TODO: Is this still relevant?
  group('Diligent SQLite Implementation', () {
    late Diligent diligent;
    late StubClock clock;
    late Map<String, Task> setupResult;

    setUpAll(() async {
      clock = StubClock();
      diligent = DiligentFactory.forUnitTests(
        dbPath: 'diligent_sqlite_implementation_test.db',
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
