import 'package:flutter_test/flutter_test.dart';

import '../helpers/dtest/dtest.dart';

Future<void> main() async {
  integrationTest('Tasks Reordering', () {
    testApp(
      'Moving task down in order',
      (dtest) async {
        final ts = await dtest.navigateToTasksPage();
        await ts.moveTask('Work', to: 'Projects');
        ts.expectTaskLayout([
          'Life',
          'Projects',
          'Work',
          'Miscellaneous',
          'Inbox',
        ]);
      },
      skip: true,
    );

    testApp('Moving task up in order', (dtest) async {
      final ts = await dtest.navigateToTasksPage();
      await ts.moveTask('Miscellaneous', to: 'Work');
      ts.expectTaskLayout([
        'Life',
        'Miscellaneous',
        'Work',
        'Projects',
        'Inbox',
      ]);
    });

    testApp('Moving top task to the bottom', (dtest) async {
      final ts = await dtest.navigateToTasksPage();
      await ts.moveTask('Life', to: 'Inbox');
      ts.expectTaskLayout([
        'Work',
        'Projects',
        'Miscellaneous',
        'Inbox',
        'Life',
      ]);
    });

    testApp('Moving bottom task to the top', (dtest) async {
      final ts = await dtest.navigateToTasksPage();
      await ts.moveTask('Inbox', to: 'Life');
      ts.expectTaskLayout([
        'Inbox',
        'Life',
        'Work',
        'Projects',
        'Miscellaneous',
      ]);
    });

    group('Moving within trees', () {
      Future<void> setupTasks(Dtest dtest) async {
        await dtest.setUpInitialTasks([
          const TestSetupTaskParam('1 Life', parent: 'Life'),
          const TestSetupTaskParam('2 Life', parent: 'Life'),
          const TestSetupTaskParam('3 Life', parent: 'Life'),
          const TestSetupTaskParam('1 Work', parent: 'Work'),
          const TestSetupTaskParam('2 Work', parent: 'Work'),
          const TestSetupTaskParam('3 Work', parent: 'Work'),
        ]);
        await dtest.expandTasks(['Life', 'Work']);
      }

      testApp('Moving a task down to a different parent', (dtest) async {
        await setupTasks(dtest);
        final ts = await dtest.navigateToTasksPage();

        await ts.moveTask('2 Life', to: '2 Work');
        ts.expectTaskLayout([
          'Life',
          '  1 Life',
          '  3 Life',
          'Work',
          '  1 Work',
          '  2 Work',
          '  2 Life',
          '  3 Work',
          'Projects',
          'Miscellaneous',
          'Inbox',
        ]);
      });

      testApp('Moving a task up to a different parent', (dtest) async {
        await setupTasks(dtest);
        final ts = await dtest.navigateToTasksPage();

        await ts.moveTask('2 Work', to: '2 Life');
        ts.expectTaskLayout([
          'Life',
          '  1 Life',
          '  2 Work',
          '  2 Life',
          '  3 Life',
          'Work',
          '  1 Work',
          '  3 Work',
          'Projects',
          'Miscellaneous',
          'Inbox',
        ]);
      });

      testApp(
        "Moving a parent's sibling task to that parent's children",
        (dtest) async {
          await setupTasks(dtest);
          final ts = await dtest.navigateToTasksPage();

          await ts.moveTask(
            'Inbox',
            to: '2 Work',
            duration: const Duration(milliseconds: 200),
          );
          ts.expectTaskLayout([
            'Life',
            '  1 Life',
            '  2 Life',
            '  3 Life',
            'Work',
            '  1 Work',
            '  Inbox',
            '  2 Work',
            '  3 Work',
            'Projects',
            'Miscellaneous',
          ]);
        },
      );

      // TODO: Figure out why this test keeps failing while the rest do not
      testApp(
        "Moving a child as a parent's sibling",
        (dtest) async {
          await setupTasks(dtest);
          final ts = await dtest.navigateToTasksPage();

          await ts.moveTask(
            '2 Life',
            to: 'Miscellaneous',
            duration: const Duration(milliseconds: 300),
          );
          ts.expectTaskLayout([
            'Life',
            '  1 Life',
            '  3 Life',
            'Work',
            '  1 Work',
            '  2 Work',
            '  3 Work',
            'Projects',
            'Miscellaneous',
            '2 Life',
            'Inbox',
          ]);
        },
        skip: true,
      );
    });
  });
}
