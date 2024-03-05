import 'package:flutter_test/flutter_test.dart';

import '../helpers/dtest/dtest.dart';

Future<void> main() async {
  integrationTest('Tasks CRUD', () {
    testApp('Adding a task', (dtest) async {
      final ts = await dtest.navigateToTasksPage();
      await ts.createTaskOnCurrentAncestor(
        'First Task',
        details: 'Some details',
      );
      ts.expectTaskExistsOnTaskList('First Task', details: 'Some details');
    });

    testApp('Adding child tasks', (dtest) async {
      final ts = await dtest.navigateToTasksPage();
      await ts.addChildTask('First Work Task', parent: 'Work');
      await ts.addChildTask('Second Work Task', parent: 'Work');
      await ts.addChildTask('First Life Task', parent: 'Life');
      await ts.addChildTask('Foo', parent: 'First Life Task');
      await ts.addChildTask('Second Life Task', parent: 'Life');
      ts.expectTaskIsChildOfParent('Foo', parent: 'First Life Task');
      ts.expectTaskIsChildOfParent('Second Life Task', parent: 'Life');
    });

    testApp('Updating a task via menu', (dtest) async {
      final ts = await dtest.navigateToTasksPage();
      await ts.createTaskOnCurrentAncestor('My Task');
      await ts.editTask('My Task', name: 'Renamed Task', details: 'I like it');
      ts.expectTaskExistsOnTaskList('Renamed Task', details: 'I like it');
    });

    testApp('Updating a task via task view', (dtest) async {
      final ts = await dtest.navigateToTasksPage();
      await ts.createTaskOnCurrentAncestor('My Task');
      await ts.editTaskViaTaskView(
        'My Task',
        name: 'Renamed Task',
        details: 'Foobar',
      );
      ts.expectTaskExistsOnTaskList('Renamed Task', details: 'Foobar');
    });

    testApp('Deleting a task via menu', (dtest) async {
      final ts = await dtest.navigateToTasksPage();
      await ts.addChildTask('First Life Task', parent: 'Life');
      await ts.deleteTask('First Life Task');
      ts.expectTaskDoesNotExistOnTaskList('First Life Task');
    });

    testApp('Deleting a task via task view', (dtest) async {
      final ts = await dtest.navigateToTasksPage();
      await ts.createTaskOnCurrentAncestor('First Task');
      ts.expectTaskExistsOnTaskList('First Task');
      await ts.deleteTaskViaTaskView('First Task');
      ts.expectTaskDoesNotExistOnTaskList('First Task');
    });
  });
}
