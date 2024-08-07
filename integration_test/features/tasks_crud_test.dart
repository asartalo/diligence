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

import '../helpers/dtest/dtest.dart';

Future<void> main() async {
  integrationTest('Tasks CRUD', () {
    testApp('Adding a task', (dtest) async {
      final ts = await dtest.navigateToTasksScreen();
      await ts.createTaskOnCurrentAncestor(
        'First Task',
        details: 'Some details',
      );
      ts.expectTaskExistsOnTaskList('First Task', details: 'Some details');
    });

    testApp('Adding child tasks', (dtest) async {
      final ts = await dtest.navigateToTasksScreen();
      await ts.addChildTask('First Work Task', parent: 'Work');
      await ts.addChildTask('Second Work Task', parent: 'Work');
      await ts.addChildTask('First Life Task', parent: 'Life');
      await ts.addChildTask('Foo', parent: 'First Life Task');
      await ts.addChildTask('Second Life Task', parent: 'Life');
      ts.expectTaskLayout([
        'Life',
        '  First Life Task',
        '    Foo',
        '  Second Life Task',
        'Work',
        '  First Work Task',
        '  Second Work Task',
        'Projects',
        'Miscellaneous',
        'Inbox',
      ]);
    });

    testApp('Updating a task via menu', (dtest) async {
      final ts = await dtest.navigateToTasksScreen();
      await ts.createTaskOnCurrentAncestor('My Task');
      await ts.editTask('My Task', name: 'Renamed Task', details: 'I like it');
      ts.expectTaskExistsOnTaskList('Renamed Task', details: 'I like it');
    });

    testApp('Updating a task via task view', (dtest) async {
      final ts = await dtest.navigateToTasksScreen();
      await ts.createTaskOnCurrentAncestor('My Task');
      await ts.editTaskViaTaskView(
        'My Task',
        name: 'Renamed Task',
        details: 'Foobar',
      );
      ts.expectTaskExistsOnTaskList('Renamed Task', details: 'Foobar');
    });

    testApp('Deleting a task via menu', (dtest) async {
      final ts = await dtest.navigateToTasksScreen();
      await ts.addChildTask('First Life Task', parent: 'Life');
      await ts.deleteTask('First Life Task');
      ts.expectTaskDoesNotExistOnTaskList('First Life Task');
    });

    testApp('Deleting a task via task view', (dtest) async {
      final ts = await dtest.navigateToTasksScreen();
      await ts.createTaskOnCurrentAncestor('First Task');
      ts.expectTaskExistsOnTaskList('First Task');
      await ts.deleteTaskViaTaskView('First Task');
      ts.expectTaskDoesNotExistOnTaskList('First Task');
    });

    group('Toggling tasks done', () {
      testApp('Toggling a single task done', (dtest) async {
        final ts = await dtest.navigateToTasksScreen();
        await ts.toggleTaskDone('Life');
        ts.expectTaskIsDone('Life');
      });

      testApp('Toggling a task as not done', (dtest) async {
        final ts = await dtest.navigateToTasksScreen();
        await ts.toggleTaskDone('Work');
        await ts.toggleTaskDone('Work');
        ts.expectTaskIsNotDone('Work');
      });

      testApp('Toggling multiple child tasks as done', (dtest) async {
        final ts = await dtest.navigateToTasksScreen();
        await ts.addChildTask('First Life Task', parent: 'Life');
        await ts.addChildTask('Second Life Task', parent: 'Life');
        await ts.toggleTaskDone('First Life Task');
        ts.expectTaskIsNotDone('Life');
        await ts.toggleTaskDone('Second Life Task');
        ts.expectTaskIsDone('Life');
      });
    });
  });
}
