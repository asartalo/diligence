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

import '../helpers/dtest/dtest.dart';

Future<void> main() async {
  integrationTest('Expanding Tasks', () {
    Future<void> setupTasks(Dtest dtest) async {
      await dtest.setUpInitialTasks([
        const SetupTaskParam('1 Life', parent: 'Life'),
        const SetupTaskParam('2 Life', parent: 'Life'),
        const SetupTaskParam('2a Life', parent: '2 Life'),
        const SetupTaskParam('2b Life', parent: '2 Life'),
        const SetupTaskParam('3 Life', parent: 'Life'),
        const SetupTaskParam('1 Work', parent: 'Work'),
        const SetupTaskParam('2 Work', parent: 'Work'),
        const SetupTaskParam('3 Work', parent: 'Work'),
      ]);
    }

    testApp('Expanding a task', (dtest) async {
      await setupTasks(dtest);
      final ts = await dtest.navigateToTasksScreen();
      await ts.toggleExpand('Life');
      ts.expectTaskLayout([
        'Life',
        '  1 Life',
        '  2 Life',
        '  3 Life',
        'Work',
        'Projects',
        'Miscellaneous',
        'Inbox',
      ]);
    });

    testApp('Contract a task subtree', (dtest) async {
      await setupTasks(dtest);
      final ts = await dtest.navigateToTasksScreen();
      await ts.toggleExpand('Life');
      await ts.toggleExpand('Life');
      ts.expectTaskLayout([
        'Life',
        'Work',
        'Projects',
        'Miscellaneous',
        'Inbox',
      ]);
    });

    testApp('Expanding descendants', (dtest) async {
      await setupTasks(dtest);
      final ts = await dtest.navigateToTasksScreen();
      await ts.toggleExpand('Life');
      await ts.toggleExpand('2 Life');
      ts.expectTaskLayout([
        'Life',
        '  1 Life',
        '  2 Life',
        '    2a Life',
        '    2b Life',
        '  3 Life',
        'Work',
        'Projects',
        'Miscellaneous',
        'Inbox',
      ]);
    });

    testApp('Expand states are persisted between screens', (dtest) async {
      await setupTasks(dtest);
      final ts = await dtest.navigateToTasksScreen();
      await ts.toggleExpand('Life');
      await ts.toggleExpand('2 Life');
      await ts.toggleExpand('Work');
      await dtest.navigateToFocusScreen();
      await dtest.navigateToTasksScreen();
      ts.expectTaskLayout([
        'Life',
        '  1 Life',
        '  2 Life',
        '    2a Life',
        '    2b Life',
        '  3 Life',
        'Work',
        '  1 Work',
        '  2 Work',
        '  3 Work',
        'Projects',
        'Miscellaneous',
        'Inbox',
      ]);
    });
  });
}
