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

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import '../helpers/dtest/dtest.dart';

Future<void> main() async {
  integrationTest('Task Reminders', () {
    Future<void> reminderSetup(Dtest dtest) async {
      await dtest.setUpInitialTasks([
        const SetupTaskParam('1 Projects', parent: 'Projects', done: true),
        const SetupTaskParam('2 Projects', parent: 'Projects'),
        const SetupTaskParam('3 Projects', parent: 'Projects'),
      ]);

      await dtest.expandTasks(['Projects']);
    }

    testApp(
      'Adding a reminder to a task',
      (dtest) async {
        await reminderSetup(dtest);
        final ts = await dtest.navigateToTasksScreen();
        final now = dtest.clock.now();
        final twoDaysAfter = now.add(const Duration(days: 2));
        await ts.addReminder('2 Projects', twoDaysAfter);
        await ts.showTask('2 Projects');
        ts.expectToSeeReminder('2 Projects', twoDaysAfter);
        ts.expectNotToSeeReminderNotice('2 Projects');
      },
    );

    testApp(
      'A reminder notice is shown on specified date and time',
      (dtest) async {
        await reminderSetup(dtest);
        final ts = await dtest.navigateToTasksScreen();
        final now = dtest.clock.now();
        const twoDays = Duration(days: 2);
        final twoDaysAfter = now.add(twoDays);
        await ts.addReminder('2 Projects', twoDaysAfter);
        await dtest.timeTravel(twoDaysAfter);
        await dtest.pumpAndSettle();
        ts.expectToSeeReminderNotice('2 Projects');
      },
    );

    testApp(
      'A reminder can be removed',
      (dtest) async {
        await reminderSetup(dtest);
        final ts = await dtest.navigateToTasksScreen();
        final now = dtest.clock.now();
        final twoDaysAfter = now.add(const Duration(days: 2));
        await ts.addReminder('2 Projects', twoDaysAfter);
        await ts.removeReminder('2 Projects', twoDaysAfter);
        ts.expectNotToSeeReminder('2 Projects', twoDaysAfter);
      },
    );

    testApp(
      'A task can be focused through the reminder',
      (dtest) async {
        await reminderSetup(dtest);
        final ts = await dtest.navigateToTasksScreen();
        final now = dtest.clock.now();
        final twoDaysAfter = now.add(const Duration(days: 2));
        await ts.addReminder('2 Projects', twoDaysAfter);
        await dtest.timeTravel(twoDaysAfter);
        await ts.focusTaskReminderNotice('2 Projects', twoDaysAfter);
        final fs = await dtest.navigateToFocusScreen();
        fs.expectFocusQueue(['2 Projects']);
      },
    );
  });
}
