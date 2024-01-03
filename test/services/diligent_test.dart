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

      test('can delete a task', () async {
        final task = await diligent.addTask(NewTask(name: 'Foo'));
        diligent.deleteTask(task!);
        expect(await diligent.findTask(task.id), isNull);
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
    });

    group('Ordering', () {
      test('it can insert new child at the beginning', () async {
        final parentTask = await diligent.addTask(NewTask(name: 'Root'));
        final task1 = await diligent.addTask(
          NewTask(name: 'Foo', parent: parentTask),
        );
        final task2 = await diligent.addTask(
          NewTask(name: 'Bar', parent: parentTask),
          position: 0,
        );
        final children = await parentTask!.children;
        expect(taskNames(children), equals([task2!.name, task1!.name]));
      });

      test('it can reorder children', () async {
        final parentTask = await diligent.addTask(NewTask(name: 'Root'));
        final task1 = await diligent.addTask(
          NewTask(name: 'Foo', parent: parentTask),
        );
        final task2 = await diligent.addTask(
          NewTask(name: 'Bar', parent: parentTask),
        );
        final task3 = await diligent.addTask(
          NewTask(name: 'Baz', parent: parentTask),
        );
        await diligent.moveTask(task3!, 1);
        final children = await parentTask!.children;
        expect(
          taskNames(children),
          equals(taskNames([task1, task3, task2])),
        );
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
  });
}

Future<Map<String, Task>> testTreeSetup(Diligent diligent) async {
  final Map<String, Task> result = {};
  final root = await diligent.addTask(NewTask(name: 'Root'));
  final a = await diligent.addTask(NewTask(name: 'A', parent: root));
  final a1 = await diligent.addTask(NewTask(name: 'A1', parent: a));
  await diligent.addTask(NewTask(name: 'A1i - leaf', parent: a1));
  await diligent.addTask(NewTask(name: 'A1ii - leaf', parent: a1));
  await diligent.addTask(NewTask(name: 'A1iii - leaf', parent: a1));
  await diligent.addTask(NewTask(name: 'A2 - leaf', parent: a));
  await diligent.addTask(NewTask(name: 'A3 - leaf', parent: a));

  final b = await diligent.addTask(NewTask(name: 'B', parent: root));
  await diligent.addTask(NewTask(name: 'B1 - leaf', parent: b));
  final b2 = await diligent.addTask(NewTask(name: 'B2', parent: b));
  await diligent.addTask(NewTask(name: 'B2i - leaf', parent: b2));
  await diligent.addTask(NewTask(name: 'B2ii - leaf', parent: b2));
  await diligent.addTask(NewTask(name: 'B2iii - leaf', parent: b2));
  await diligent.addTask(NewTask(name: 'B3', parent: b));
  final c = await diligent.addTask(NewTask(name: 'C', parent: root));

  result['Root'] = root!;
  result['A'] = a!;
  result['A1'] = a1!;
  result['B'] = b!;
  result['B2'] = b2!;
  result['C'] = c!;

  return result;
}
