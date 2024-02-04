import 'package:diligence/models/leveled_task.dart';
import 'package:diligence/models/new_task.dart';
import 'package:diligence/models/task.dart';
import 'package:diligence/services/diligent.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> taskNames(List<Task?> tasks) {
  final List<String> names = [];
  for (final task in tasks) {
    if (task != null) {
      names.add(task.name);
    }
  }
  return names;
}

void main() {
  group('Diligent', () {
    late Diligent diligent;

    setUpAll(() {
      diligent = Diligent.forTests();
      diligent.runMigrations();
    });

    tearDown(() {
      diligent.clearDataForTests();
    });

    group('Basic CRUD', () {
      test('can create a root task', () async {
        final task = await diligent.addTask(NewTask(name: 'Root'));
        expect(task?.name, equals('Root'));
      });

      test('persists task', () async {
        final id = (await diligent.addTask(NewTask(
          name: 'Foo',
          details: 'Bar',
        )))!
            .id;
        final task = await diligent.findTask(id);
        expect(task!.name, equals('Foo'));
        expect(task.details, equals('Bar'));
      });

      test('increments childrenCount when a child task is added', () async {
        final parentTask = await diligent.addTask(NewTask(name: 'Root'));
        await diligent.addTask(NewTask(name: 'Foo', parent: parentTask));
        final tasks = await diligent.subtreeFlat(parentTask!.id);
        expect((tasks.first as LeveledTask).childrenCount, equals(1));
      });

      test('can delete a task', () async {
        final task = await diligent.addTask(NewTask(name: 'Foo'));
        await diligent.deleteTask(task!);
        expect(await diligent.findTask(task.id), isNull);
      });

      test('decrements childrenCount when a child task is deleted', () async {
        final parentTask = await diligent.addTask(NewTask(name: 'Root'));
        final task = await diligent.addTask(
          NewTask(name: 'Foo', parent: parentTask),
        );
        await diligent.deleteTask(task!);
        final tasks = await diligent.subtreeFlat(parentTask!.id);
        expect((tasks.first as LeveledTask).childrenCount, equals(0));
      });

      test('can find task by name', () async {
        await diligent.addTask(NewTask(name: 'Root'));
        final task = await diligent.findTaskByName('root');
        expect(task?.name, equals('Root'));
      });
    });

    group('Hierarchy', () {
      late Task parentTask;

      setUp(() async {
        parentTask = (await diligent.addTask(NewTask(name: 'Root')))!;
      });

      test('node with no children has 0 childCount', () async {
        final tasks = await diligent.subtreeFlat(parentTask.id);
        expect((tasks.first as LeveledTask).childrenCount, equals(0));
      });

      test('it can set a parent to a task', () async {
        final task = await diligent
            .addTask(NewTask(name: 'Foo', parentId: parentTask.id));
        final children = await parentTask.children;
        expect(children.first.name, equals(task!.name));
        expect((await task.parent)!.name, equals(parentTask.name));
      });

      test('it appends new children to parent', () async {
        final task1 = await diligent.addTask(
          NewTask(name: 'Foo', parent: parentTask),
        );
        final task2 = await diligent.addTask(
          NewTask(name: 'Bar', parent: parentTask),
        );
        expect(
          taskNames(await parentTask.children),
          equals(taskNames([task1, task2])),
        );
      });

      test('it can insert child to a position', () async {
        final task1 = await diligent.addTask(
          NewTask(name: 'Foo', parent: parentTask),
        );
        final task2 = await diligent.addTask(
          NewTask(name: 'Bar', parent: parentTask),
          position: 0,
        );
        expect(
          taskNames(await parentTask.children),
          equals(taskNames([task2, task1])),
        );
      });
    });

    group('Moving Tasks', () {
      group('Within Siblings', () {
        late Task parentTask;

        setUp(() async {
          parentTask = (await diligent.addTask(NewTask(name: 'Root')))!;
          for (final taskName in ['A', 'B', 'C', 'D', 'E']) {
            await diligent.addTask(NewTask(name: taskName, parent: parentTask));
          }
        });

        test('it can insert new child at the beginning', () async {
          await diligent.addTask(
            NewTask(name: 'Bar', parent: parentTask),
            position: 0,
          );
          final children = await parentTask.children;
          expect(taskNames(children), equals(['Bar', 'A', 'B', 'C', 'D', 'E']));
        });

        test('it can move task up', () async {
          final task = (await diligent.findTaskByName('D'))!;
          await diligent.moveTask(task, 1);
          final children = await parentTask.children;
          expect(
            taskNames(children),
            equals(['A', 'D', 'B', 'C', 'E']),
          );
        });

        test('it can move task down', () async {
          final task = (await diligent.findTaskByName('B'))!;
          await diligent.moveTask(task, 3);
          final children = await parentTask.children;
          expect(
            taskNames(children),
            equals(['A', 'C', 'D', 'B', 'E']),
          );
        });

        test('it limits movement to last position', () async {
          final task = (await diligent.findTaskByName('B'))!;
          await diligent.moveTask(task, 10);
          final children = await parentTask.children;
          expect(
            taskNames(children),
            equals(['A', 'C', 'D', 'E', 'B']),
          );
        });

        test('it limits movement to first position', () async {
          final task = (await diligent.findTaskByName('B'))!;
          await diligent.moveTask(task, -3);
          final children = await parentTask.children;
          expect(
            taskNames(children),
            equals(['B', 'A', 'C', 'D', 'E']),
          );
        });
      });

      group('Between Different Nodes and Subtrees', () {
        late Map<String, Task> setupResult;

        setUp(() async {
          setupResult = await testTreeSetup(diligent);
        });

        test('it can move task to a different node', () async {
          final task = setupResult['B2']!;
          final oldParent = setupResult['B']!;
          final newParent = setupResult['A1']!;
          await diligent.moveTask(task, 0, parent: newParent);
          final newSiblings = await newParent.children;
          expect(
            taskNames(newSiblings),
            equals(['B2', 'A1i - leaf', 'A1ii - leaf', 'A1iii - leaf']),
          );
          final oldSiblings = await oldParent.children;
          expect(
            taskNames(oldSiblings),
            equals(['B1 - leaf', 'B3 - leaf']),
          );
        });

        test('it can move task to a different node to a different position',
            () async {
          final task = setupResult['B2']!;
          final newParent = setupResult['A1']!;
          await diligent.moveTask(task, 2, parent: newParent);
          final newSiblings = await newParent.children;
          expect(
            taskNames(newSiblings),
            equals(['A1i - leaf', 'A1ii - leaf', 'B2', 'A1iii - leaf']),
          );
        });
      });
    });

    group('Initial Data', () {
      setUp(() async {
        await diligent.initialAreas(initialAreas);
      });

      test('creates root node', () async {
        final root = await diligent.findTask(1);
        expect(root!.name, equals('Root'));
      });

      test('it can initialize with basic data', () async {
        final root = await diligent.findTask(1);
        expect(
          taskNames(await diligent.getChildren(root!)),
          [
            'Life',
            'Work',
            'Projects',
            'Miscellaneous',
            'Inbox',
          ],
        );
      });

      test('it does nothing when called again', () async {
        await diligent.initialAreas(initialAreas);
        final tasks = await diligent.subtreeFlat(1);
        expect(
          taskNames(tasks),
          equals([
            'Root',
            'Life',
            'Work',
            'Projects',
            'Miscellaneous',
            'Inbox',
          ]),
        );
      });
    });

    group('Focus Queue', () {
      late Map<String, Task> setupResult;

      setUp(() async {
        setupResult = await testTreeSetup(diligent);
      });

      Future<void> focusItems(List<String> tasksNames) async {
        for (final taskName in tasksNames) {
          await diligent.focus(setupResult[taskName]!);
        }
      }

      test('it has no focusQueue by default', () async {
        final queue = await diligent.focusQueue();
        expect(queue, isEmpty);
      });

      test('it can add a task to focusQueue', () async {
        final task = setupResult['A1i - leaf']!;
        await diligent.focus(task);
        final queue = await diligent.focusQueue();
        expect(queue.first.id, equals(task.id));
      });

      test('it automatically adds new task first on queue', () async {
        await focusItems(['A1i - leaf', 'A2 - leaf', 'B1 - leaf']);
        final queue = await diligent.focusQueue();
        expect(
          taskNames(queue),
          equals([
            'B1 - leaf',
            'A2 - leaf',
            'A1i - leaf',
          ]),
        );
      });

      test('it can add a new task to queue on a specific position', () async {
        await focusItems(['A1i - leaf', 'A2 - leaf', 'B1 - leaf']);
        await diligent.focus(setupResult['C - leaf']!, position: 1);
        expect(
          taskNames(await diligent.focusQueue()),
          equals([
            'B1 - leaf',
            'C - leaf',
            'A2 - leaf',
            'A1i - leaf',
          ]),
        );
      });

      test('it can remove a task from focusQueue', () async {
        await focusItems(['A1i - leaf', 'A2 - leaf', 'B1 - leaf']);
        await diligent.focus(setupResult['C - leaf']!, position: 1);
        await diligent.unfocus(setupResult['A2 - leaf']!);
        expect(
          taskNames(await diligent.focusQueue()),
          equals([
            'B1 - leaf',
            'C - leaf',
            'A1i - leaf',
          ]),
        );
      });

      test(
          'when adding an ancestor task, it adds its descendant leaf tasks to the queue',
          () async {
        await diligent.focus(setupResult['A1i - leaf']!);
        await diligent.focus(setupResult['B']!);
        expect(
          taskNames(await diligent.focusQueue()),
          equals([
            'B1 - leaf',
            'B2i - leaf',
            'B2ii - leaf',
            'B2iii - leaf',
            'B3 - leaf',
            'A1i - leaf',
          ]),
        );
      });

      test(
          'when adding an ancestor task with position, it adds its descendant leaf tasks to the queue on that position',
          () async {
        await focusItems(['A1i - leaf', 'C - leaf']);
        await diligent.focus(setupResult['B']!, position: 1);
        expect(
          taskNames(await diligent.focusQueue()),
          equals([
            'C - leaf',
            'B1 - leaf',
            'B2i - leaf',
            'B2ii - leaf',
            'B2iii - leaf',
            'B3 - leaf',
            'A1i - leaf',
          ]),
        );
      });

      test('when a task is deleted, it is also unfocused', () async {
        final task = setupResult['C - leaf']!;
        await diligent.focus(setupResult['A1i - leaf']!);
        await diligent.focus(task);
        await diligent.deleteTask(task);
        expect(
          taskNames(await diligent.focusQueue()),
          equals([
            'A1i - leaf',
          ]),
        );
      });

      test('when a task is marked as done, it is also unfocused', () async {
        final task = setupResult['C - leaf']!;
        await diligent.focus(setupResult['A1i - leaf']!);
        await diligent.focus(task);
        await diligent.updateTask(task.copyWith(done: true));
        expect(
          taskNames(await diligent.focusQueue()),
          equals([
            'A1i - leaf',
          ]),
        );
      });
    });

    test('it can find all leaves on a subtree', () async {
      final Map<String, Task> setupResult = await testTreeSetup(diligent);
      final leaves = await diligent.leaves(setupResult['A']!);
      expect(
        taskNames(leaves),
        equals([
          'A1i - leaf',
          'A1ii - leaf',
          'A1iii - leaf',
          'A2 - leaf',
          'A3 - leaf',
        ]),
      );
    });

    test('it can update a task', () async {
      final task = await diligent.addTask(NewTask(name: 'Foo'));
      await diligent.updateTask(task!.copyWith(name: 'Bar'));
      final updatedTask = await diligent.findTask(task.id);
      expect(updatedTask?.name, equals('Bar'));
    });

    group('subtreeFlat()', () {
      late Map<String, Task> setupResult;

      setUp(() async {
        setupResult = await testTreeSetup(diligent);
      });

      test('it returns subtree as a flat list', () async {
        final aTask = setupResult['A'];
        if (aTask == null) {
          fail('Unexpected result. testTreeSetup() did not work.');
        }
        final TaskList tasks = await diligent.subtreeFlat(aTask.id);
        final nameList = <String>[];
        for (final task in tasks) {
          nameList.add(task.name);
        }
        expect(
          nameList,
          equals(
            [
              'A',
              'A1',
              'A1i - leaf',
              'A1ii - leaf',
              'A1iii - leaf',
              'A2 - leaf',
              'A3 - leaf',
            ],
          ),
        );
      });
    });

    group('expandedDescendantsTree()', () {
      late Map<String, Task> setupResult;

      setUp(() async {
        setupResult = await testTreeSetup(diligent);
      });

      test('it returns subtree starting from descendants including of root',
          () async {
        final rootTask = setupResult['Root'];
        if (rootTask == null) {
          fail('Unexpected result. testTreeSetup() did not work.');
        }
        final TaskList tasks = await diligent.expandedDescendantsTree(rootTask);
        final nameList = <String>[];
        for (final task in tasks) {
          nameList.add(task.name);
        }
        expect(
          nameList,
          equals(
            [
              'A',
              'A1',
              'A2 - leaf',
              'A3 - leaf',
              'B',
              'B1 - leaf',
              'B2',
              'B3 - leaf',
              'C - leaf',
            ],
          ),
        );
      });
    });
  });
}

Future<Map<String, Task>> testTreeSetup(Diligent diligent) async {
  final Map<String, Task> result = {};
  final root = await diligent.addTask(NewTask(name: 'Root'));
  final a = await diligent.addTask(
    NewTask(name: 'A', parent: root, expanded: true),
  );
  final a1 = await diligent.addTask(NewTask(name: 'A1', parent: a));
  final a2 = await diligent.addTask(NewTask(name: 'A2 - leaf', parent: a));
  await diligent.addTask(NewTask(name: 'A1ii - leaf', parent: a1));
  await diligent.addTask(NewTask(name: 'A3 - leaf', parent: a));
  await diligent.addTask(NewTask(name: 'A1iii - leaf', parent: a1));
  final a1ILeaf = await diligent.addTask(
    NewTask(name: 'A1i - leaf', parent: a1),
    position: 0,
  );

  final c = await diligent.addTask(NewTask(name: 'C - leaf', parent: root));

  final b = await diligent.addTask(
    NewTask(name: 'B', parent: root, expanded: true),
    position: 1,
  );
  final b1Leaf = await diligent.addTask(
    NewTask(name: 'B1 - leaf', parent: b, expanded: true),
  );
  final b2 = await diligent.addTask(NewTask(name: 'B2', parent: b));
  await diligent.addTask(NewTask(name: 'B2i - leaf', parent: b2));
  await diligent.addTask(NewTask(name: 'B2ii - leaf', parent: b2));
  await diligent.addTask(NewTask(name: 'B3 - leaf', parent: b));
  await diligent.addTask(NewTask(name: 'B2iii - leaf', parent: b2));

  result['Root'] = root!;
  result['A'] = a!;
  result['A1'] = a1!;
  result['B'] = b!;
  result['B2'] = b2!;
  result['C - leaf'] = c!;
  result['A2 - leaf'] = a2!;
  result['A1i - leaf'] = a1ILeaf!;
  result['B1 - leaf'] = b1Leaf!;

  return result;
}
