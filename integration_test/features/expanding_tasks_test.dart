import '../helpers/dtest/dtest.dart';

Future<void> main() async {
  integrationTest('Expanding Tasks', () {
    Future<void> setupTasks(Dtest dtest) async {
      await dtest.setUpInitialTasks([
        const TestSetupTaskParam('1 Life', parent: 'Life'),
        const TestSetupTaskParam('2 Life', parent: 'Life'),
        const TestSetupTaskParam('2a Life', parent: '2 Life'),
        const TestSetupTaskParam('2b Life', parent: '2 Life'),
        const TestSetupTaskParam('3 Life', parent: 'Life'),
        const TestSetupTaskParam('1 Work', parent: 'Work'),
        const TestSetupTaskParam('2 Work', parent: 'Work'),
        const TestSetupTaskParam('3 Work', parent: 'Work'),
      ]);
    }

    testApp('Expanding a task', (dtest) async {
      await setupTasks(dtest);
      final ts = await dtest.navigateToTasksPage();
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
      final ts = await dtest.navigateToTasksPage();
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
      final ts = await dtest.navigateToTasksPage();
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
      final ts = await dtest.navigateToTasksPage();
      await ts.toggleExpand('Life');
      await ts.toggleExpand('2 Life');
      await ts.toggleExpand('Work');
      await dtest.navigateToFocusPage();
      await dtest.navigateToTasksPage();
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
