import 'package:diligence/models/modified_task.dart';
import 'package:diligence/models/persisted_task.dart';
import 'package:diligence/models/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ModifiedTask', () {
    late ModifiedTask task;
    late PersistedTask persistedTask;
    final now = DateTime.now();

    setUp(() {
      persistedTask = PersistedTask(
        name: 'Foo',
        details: 'Bar',
        parentId: 1,
        uid: '1234',
        createdAt: now,
        updatedAt: now,
      );
      task = ModifiedTask(
        originalTask: persistedTask,
        name: 'FooBaz',
        details: 'BarBaz',
        parentId: 1,
      );
    });

    test('should be a Task', () {
      expect(task, isA<Task>());
    });

    test('it modifies correct fields', () {
      expect(task.name, equals('FooBaz'));
      expect(task.details, equals('BarBaz'));
      expect(task.parentId, equals(1));
    });

    test('it can identify which fields were modified', () {
      expect(task.modifiedFields(), equals({'name', 'details'}));
    });

    test('it can identify whether a field was modified', () {
      expect(task.isModified('name'), isTrue);
      expect(task.isModified('details'), isTrue);
      expect(task.isModified('parentId'), isFalse);
    });

    test('it identifies that doneAt had been changed when marked as done', () {
      final modified = task.markDone() as ModifiedTask;
      expect(modified.modifiedFields(), contains('doneAt'));
    });

    test('it updates updatedAt when modified', () {
      expect(task.updatedAt.isAfter(now), isTrue);
    });

    test('it updates updatedAt when modified', () {
      expect(task.updatedAt.isAfter(now), isTrue);
    });

    test('it updates updatedAt when task is modified again', () {
      final modified = task.copyWith(name: 'FooBaz');
      expect(modified.updatedAt.isAfter(task.updatedAt), isTrue);
    });
  });
}
