import 'package:flutter_test/flutter_test.dart';

import '../helpers/dtest/dtest.dart';

Future<void> main() async {
  integrationTest('Focus Tasks', () {
    testApp(
      'Focusing a task adds it to focus queue with last focused first',
      (dtest) async {
        final ts = await dtest.navigateToTasksPage();
        await ts.focusTask('Work');
        await ts.focusTask('Life');
        await ts.focusTask('Inbox');
        final fs = await dtest.navigateToFocusPage();
        fs.expectFocusQueue(['Inbox', 'Life', 'Work']);
      },
    );

    testApp(
      'Focusing a task with children adds the leaf nodes to the queue',
      (dtest) async {
        await dtest.setUpInitialTasks([
          const TestSetupTaskParam('1 Inbox', parent: 'Inbox'),
          const TestSetupTaskParam('2 Inbox', parent: 'Inbox', done: true),
          const TestSetupTaskParam('3 Inbox', parent: 'Inbox'),
        ]);
        await dtest.setUpInitialTasks([
          const TestSetupTaskParam('3a Inbox', parent: '3 Inbox', done: true),
          const TestSetupTaskParam('3b Inbox', parent: '3 Inbox'),
        ]);
        final ts = await dtest.navigateToTasksPage();
        await ts.focusTask('Inbox');
        final fs = await dtest.navigateToFocusPage();
        fs.expectFocusQueue(['1 Inbox', '3b Inbox']);
      },
    );

    testApp('Unfocusing a task', (dtest) async {
      await dtest.setUpFocusedTasks(['Work', 'Life', 'Inbox']);
      final fs = await dtest.navigateToFocusPage();
      await fs.unfocusTask('Life');
      fs.expectFocusQueue(['Work', 'Inbox']);
    });

    testApp('Marking tasks as done', (dtest) async {
      await dtest.setUpFocusedTasks(['Work', 'Life', 'Inbox']);
      final fs = await dtest.navigateToFocusPage();
      await fs.deleteTask('Inbox');
      fs.expectFocusQueue(['Work', 'Life']);
    });

    testApp('Editing a task', (dtest) async {
      await dtest.setUpFocusedTasks(['Work', 'Life', 'Inbox']);
      final fs = await dtest.navigateToFocusPage();
      await fs.editTask('Inbox', name: 'My Inbox');
      fs.expectFocusQueue(['Work', 'Life', 'My Inbox']);
    });

    testApp('Deleting a task', (dtest) async {
      await dtest.setUpFocusedTasks(['Work', 'Life', 'Inbox']);
      final fs = await dtest.navigateToFocusPage();
      await fs.deleteTask('Inbox');
      fs.expectFocusQueue(['Work', 'Life']);
      final ts = await dtest.navigateToTasksPage();
      ts.expectTaskLayout([
        'Life',
        'Work',
        'Projects',
        'Miscellaneous',
      ]);
    });

    group('Reordering focused tasks', () {
      testApp('Reordering a task up', (dtest) async {
        await dtest.setUpFocusedTasks(['Work', 'Life', 'Inbox']);
        final fs = await dtest.navigateToFocusPage();
        await fs.moveTask('Inbox', to: 'Life');
        fs.expectFocusQueue(['Work', 'Inbox', 'Life']);
      });

      testApp('Reordering a task down', (dtest) async {
        await dtest.setUpFocusedTasks(['Work', 'Life', 'Inbox']);
        final fs = await dtest.navigateToFocusPage();
        await fs.moveTask(
          'Work',
          to: 'Life',
          duration: const Duration(milliseconds: 200),
        );
        fs.expectFocusQueue(['Life', 'Work', 'Inbox']);
      });
    });
  });
}
