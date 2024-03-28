import 'package:diligence/models/new_task.dart';
import 'package:diligence/models/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NewTask', () {
    late Task task;

    setUp(() {
      task = NewTask(
        name: 'Foo',
        details: 'Bar',
        parentId: 1,
      );
    });

    test('should be a Task', () {
      expect(task, isA<Task>());
    });

    test('should have a createdAt and updatedAt', () {
      expect(task.createdAt, isA<DateTime>());
      expect(task.updatedAt, isA<DateTime>());
    });

    test('should have a uid', () {
      expect(
        task.uid,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
          ),
        ),
      );
    });

    group('#markDone()', () {
      late Task doneTask;
      setUp(() {
        doneTask = task.markDone();
      });

      test('should return a Task with doneAt set to now', () {
        expect(doneTask.doneAt, isA<DateTime>());
      });

      test('should return a Task with done set to true', () {
        expect(doneTask.done, isTrue);
      });
    });

    group('#markNotDone()', () {
      late Task notDoneTask;
      setUp(() {
        notDoneTask = task.markDone().markNotDone();
      });

      test('should return a Task with doneAt set to null', () {
        expect(notDoneTask.doneAt, isNull);
      });

      test('should return a Task with done set to false', () {
        expect(notDoneTask.done, isFalse);
      });
    });
  });
}
