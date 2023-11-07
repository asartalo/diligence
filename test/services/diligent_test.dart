import 'package:diligence/constants.dart';
import 'package:diligence/model/objectbox.dart';
import 'package:diligence/model/task.dart';
import 'package:diligence/objectbox.g.dart';
import 'package:diligence/services/diligent.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Diligent', () {
    late Diligent diligent;
    late Store store;

    setUp(() async {
      store = await openStore(directory: Paths.testTmp);
      final objectbox = await ObjectBox.create(store);
      diligent = Diligent(objectbox: objectbox);
    });

    tearDown(() {
      store.close();
    });

    test('it can create a root task', () {
      final task = diligent.addTask(name: 'Root');
      expect(task.name, equals('Root'));
    });

    test('it persists task', () {
      final id = (diligent.addTask(name: 'Foo')).id;
      final task = diligent.findTask(id);
      expect(task!.name, equals('Foo'));
    });

    test('it can delete a task', () {
      final task = diligent.addTask(name: 'Foo');
      diligent.deleteTask(task.id);
      expect(diligent.findTask(task.id), isNull);
    });

    test('it can set a parent to a task', () {
      final parentTask = diligent.addTask(name: 'Root');
      final task = diligent.addTask(name: 'Foo', parentId: parentTask.id);
      expect(parentTask.children.first.name, equals(task.name));
    });

    group('subtreeFlat()', () {
      late Map<String, Task> setupResult;
      setUp(() {
        setupResult = subtreeTestSetup(diligent);
      });

      test('it returns subtree as a flat list', () {
        final aTask = setupResult['A'];
        if (aTask == null) {
          fail('Unexpected result. subtreeSetup() did not work.');
        }
        final TaskList tasks = diligent.subtreeFlat(aTask.id);
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

Map<String, Task> subtreeTestSetup(Diligent diligent) {
  final Map<String, Task> result = {};
  diligent.taskWriteTransaction(() {
    final root = diligent.addTask(name: 'Root');
    final a = diligent.addTask(name: 'A', parent: root);
    final a1 = diligent.addTask(name: 'A1', parent: a);
    diligent.addTask(name: 'A1i - leaf', parent: a1);
    diligent.addTask(name: 'A1ii - leaf', parent: a1);
    diligent.addTask(name: 'A1iii - leaf', parent: a1);
    diligent.addTask(name: 'A2 - leaf', parent: a);
    diligent.addTask(name: 'A3 - leaf', parent: a);

    final b = diligent.addTask(name: 'B', parent: root);
    diligent.addTask(name: 'B1 - leaf', parent: b);
    final b2 = diligent.addTask(name: 'B2', parent: b);
    diligent.addTask(name: 'B2i - leaf', parent: b2);
    diligent.addTask(name: 'B2ii - leaf', parent: b2);
    diligent.addTask(name: 'B2iii - leaf', parent: b2);
    diligent.addTask(name: 'B3', parent: b);
    final c = diligent.addTask(name: 'C', parent: root);

    result['Root'] = root;
    result['A'] = a;
    result['A1'] = a1;
    result['B'] = b;
    result['B2'] = b2;
    result['C'] = c;
  });

  return result;
}
