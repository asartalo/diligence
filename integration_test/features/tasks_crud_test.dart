import 'package:diligence/ui/keys.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/dtest.dart';
import '../helpers/interactions.dart';
import '../helpers/navigation.dart';

Future<void> main() async {
  integrationTest('Tasks CRUD', () {
    testApp('Adding a task', (WidgetTester tester) async {
      await navigateToTasksPage(tester);
      await tapByKey(tester, addTaskFloatingButton);
      await tester.enterText(find.byKey(addTaskTaskNameField), 'First Task');
      await tapByKey(tester, addTaskSaveButton);
      final taskList = find.byKey(tasksTaskList);
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
