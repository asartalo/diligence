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

import 'package:flutter_test/flutter_test.dart';

import '../../helpers/dtest/dtest.dart';

Future<void> main() async {
  integrationTest('Day Log', () {
    testApp('Shows log', (dtest) async {
      await dtest.navigateToReminderPage();
      // final dayLogField = find.byKey(const Key('fieldDayLogNotes'));
      // await tester.enterText(dayLogField, 'This is a log');
      // await tester.tap(find.byKey(const Key('btnSaveLog')));
      // await tester.pumpAndSettle();
      // final dayLogText = find.byKey(const Key('txtDayLogNotes'));
      // final foo = dayLogText.evaluate().single.widget as MarkdownBody;
      // expect(foo.data, contains('This is a log'));
    });
  });
}
