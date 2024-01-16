import 'package:diligence/ui/screens/tasks/keys.dart' as keys;
import 'package:flutter_test/flutter_test.dart';

import '../helpers/dtest/dtest.dart';

Future<void> main() async {
  integrationTest('Tasks CRUD', () {
    testApp('Adding a task', (dtest) async {
      await dtest.navigateToTasksPage();
      await dtest.tapByKey(keys.addTaskFloatingButton);
      await dtest.enterTextByKey(keys.taskNameField, 'First Task');
      await dtest.enterTextByKey(keys.taskDetailsField, 'Some details');
      await dtest.tapByKey(keys.saveTaskButton);
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

    testApp('Updating a task', (dtest) async {
      await dtest.navigateToTasksPage();
      await dtest.tapByKey(keys.addTaskFloatingButton);
      await dtest.enterTextByKey(keys.taskNameField, 'My Task');
      await dtest.tapByKey(keys.saveTaskButton);
      final taskList = find.byKey(keys.mainTaskList);
      final task = find.descendant(
        of: taskList,
        matching: find.text('My Task'),
      );
      await dtest.tapElement(task);
      await dtest.enterTextByKey(keys.taskNameField, 'Renamed Task');
      await dtest.tapByKey(keys.saveTaskButton);

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
