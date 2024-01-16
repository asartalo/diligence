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
      await tester.enterText(find.byKey(keys.taskDetailsField), 'Some details');
      await tapByKey(tester, keys.saveTaskButton);
      final taskList = find.byKey(keys.mainTaskList);
      expect(
        find.descendant(
          of: taskList,
          matching: find.text('First Task'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: taskList,
          matching: find.text('Some details'),
        ),
        findsOneWidget,
      );
    });

    testApp('Updating a task', (WidgetTester tester) async {
      await navigateToTasksPage(tester);
      await tapByKey(tester, keys.addTaskFloatingButton);
      await tester.enterText(find.byKey(keys.taskNameField), 'My Task');
      await tapByKey(tester, keys.saveTaskButton);
      final taskList = find.byKey(keys.mainTaskList);
      final task = find.descendant(
        of: taskList,
        matching: find.text('My Task'),
      );
      await tapElement(tester, task);
      await tester.enterText(find.byKey(keys.taskNameField), 'Renamed Task');
      await tapByKey(tester, keys.saveTaskButton);

      expect(
        find.descendant(
          of: taskList,
          matching: find.text('Renamed Task'),
        ),
        findsOneWidget,
      );
    });
  });
}
