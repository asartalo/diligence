import 'package:diligence/models/modified_task.dart';
import 'package:diligence/models/persisted_task.dart';
import 'package:diligence/models/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PersistedTask', () {
    late PersistedTask task;

    setUp(() {
      task = PersistedTask(
        name: 'Foo',
        details: 'Bar',
        parentId: 1,
        uid: '1234',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    test('should be a Task', () {
      expect(task, isA<Task>());
    });
  });

  group('#copyWith()', () {
    late Task task;
    final now = DateTime.now();
    final nowPlusOne = now.add(const Duration(seconds: 1));
    final nowPlusTwo = now.add(const Duration(seconds: 2));

    group('with all fields', () {
      late Task copy;
      setUp(() {
        task = PersistedTask(
          name: 'Foo',
          details: 'Bar',
          parentId: 1,
          uid: '1234',
          createdAt: now,
          updatedAt: now,
        );
        copy = task.copyWith(
          name: 'Baz',
          details: 'Qux',
          parentId: 2,
          doneAt: nowPlusOne,
          expanded: true,
          now: nowPlusOne,
        );
      });

      test('should return a new Task with the specified fields', () {
        expect(copy.name, equals('Baz'));
        expect(copy.details, equals('Qux'));
        expect(copy.parentId, equals(2));
        expect(copy.doneAt, nowPlusOne);
        expect(copy.expanded, isTrue);
      });

      test('should return a new Task with the same id', () {
        expect(copy.id, equals(task.id));
      });
    });

    test('copy is an instance of ModifiedTask', () {
      final copy = task.copyWith(name: 'Baz', now: nowPlusTwo);
      expect(copy, isA<ModifiedTask>());
    });

    test('should not copy `doneAt` field if not specified', () {
      final copy1 = task.copyWith(doneAt: nowPlusOne, now: nowPlusOne);
      expect(copy1.doneAt, nowPlusOne);
      final copy2 = copy1.copyWith(name: 'Baz', now: nowPlusOne);
      expect(copy2.doneAt, nowPlusOne);
    });

    test('should set `doneAt` when done is set', () {
      final copy = task.copyWith(name: 'Baz', done: true, now: nowPlusTwo);
      expect(copy.doneAt, isA<DateTime>());
    });

    test('should set `doneAt` when done is set to true', () {
      final copy = task.copyWith(name: 'Baz', done: true, now: nowPlusTwo);
      expect(copy.doneAt, isA<DateTime>());
    });

    test('should set `doneAt` to null when done is set to false', () {
      final copy = task
          .copyWith(done: true, now: nowPlusTwo)
          .copyWith(done: false, now: nowPlusTwo);
      expect(copy.doneAt, isNull);
    });
  });
}
