import 'package:diligence/ui/screens/tasks/keys.dart' as keys;
import 'package:flutter_test/flutter_test.dart';

import '../helpers/dtest.dart';
import '../helpers/interactions.dart';
import '../helpers/navigation.dart';

Future<void> main() async {
  integrationTest('Tasks CRUD', () {
    testApp('Adding a task', (WidgetTester tester) async {
      await navigateToTasksPage(tester);
      await tapByKey(tester, keys.addTaskFloatingButton);
      await tester.enterText(find.byKey(keys.taskNameField), 'First Task');
      await tapByKey(tester, keys.saveTaskButton);
      final taskList = find.byKey(keys.mainTaskList);
      expect(
        find.descendant(
          of: taskList,
          matching: find.text('First Task'),
        ),
        findsOneWidget,
      );
    });
  });
}
