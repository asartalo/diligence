import 'package:diligence/models/commands/commands.dart';
import 'package:diligence/models/new_task.dart';
import 'package:diligence/models/persisted_task.dart';
import 'package:diligence/services/diligent.dart';
import 'package:diligence/services/diligent/commander.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDiligent extends Mock implements Diligent {}

class UnknownCommand extends Command {}

void main() {
  group('DiligentCommander', () {
    late DiligentCommander commander;
    late Diligent diligent;

    setUp(() async {
      diligent = MockDiligent();
      commander = DiligentCommander(diligent);
    });

    PersistedTask createPersistedTask({DateTime? now}) {
      final nowReally = now ?? DateTime.now();
      return PersistedTask(
        id: 1,
        name: 'Foo',
        createdAt: nowReally,
        uid: 'foo',
        updatedAt: nowReally,
      );
    }

    group('#handle()', () {
      late CommandResult result;

      group('NewTaskCommand', () {
        final newTask = NewTask(name: 'Foo');
        final command = NewTaskCommand(payload: newTask);

        group('when successful', () {
          setUp(() async {
            final now = DateTime.now();
            when(() => diligent.addTask(newTask)).thenAnswer(
              (_) async => createPersistedTask(now: now),
            );
            result = await commander.handle(command);
          });

          test('it returns Success', () {
            expect(result, isA<Success>());
          });

          test('it returns a success message', () {
            expect(
              result.message,
              'Task "${newTask.name}" added successfully.',
            );
          });

          test('it returns the persisted task as payload', () {
            expect((result as SuccessPack).payload, isA<PersistedTask>());
          });
        });

        group('when unsuccessful', () {
          final exception = Exception('foo');
          setUp(() async {
            when(() => diligent.addTask(newTask)).thenThrow(exception);
            result = await commander.handle(command);
          });

          test('it returns Fail', () {
            expect(result, isA<Fail>());
          });

          test('it returns a failure message', () {
            expect(result.message, 'Failed to add task "Foo".');
          });

          test('it returns the exception as payload', () {
            expect((result as FailPack).payload, exception);
          });
        });
      });

      group('DeleteTaskCommand', () {
        final task = createPersistedTask();
        final command = DeleteTaskCommand(payload: task);

        group('when successful', () {
          setUp(() async {
            when(() => diligent.deleteTask(task)).thenAnswer((_) async {});
            result = await commander.handle(command);
          });

          test('it returns Success', () {
            expect(result, isA<Success>());
          });

          test('it returns a success message', () {
            expect(result.message,
                'Task "${task.name}" was deleted successfully.');
          });
        });

        group('when unsuccessful', () {
          final exception = Exception('foo');
          setUp(() async {
            when(() => diligent.deleteTask(task)).thenThrow(exception);
            result = await commander.handle(command);
          });

          test('it returns Fail', () {
            expect(result, isA<Fail>());
          });

          test('it returns a failure message', () {
            expect(result.message, 'Failed to delete task "Foo".');
          });

          test('it returns the exception as payload', () {
            expect((result as FailPack).payload, exception);
          });
        });
      });

      group('UpdateTaskCommand', () {
        final now = DateTime.now();
        final originalTask = createPersistedTask(now: now);
        final task = originalTask.copyWith(name: 'Bar');
        final command = UpdateTaskCommand(payload: task);

        group('when successful', () {
          setUp(() async {
            when(() => diligent.updateTask(task)).thenAnswer((_) async {
              return PersistedTask(
                id: 1,
                name: 'Bar',
                createdAt: now,
                uid: 'foo',
                updatedAt: task.updatedAt,
              );
            });
            result = await commander.handle(command);
          });

          test('it returns Success', () {
            expect(result, isA<Success>());
          });

          test('it returns a success message', () {
            expect(
              result.message,
              'Task "Bar" was updated successfully.',
            );
          });
        });

        group('when unsuccessful', () {
          final exception = Exception('foo');
          setUp(() async {
            when(() => diligent.updateTask(task)).thenThrow(exception);
            result = await commander.handle(command);
          });

          test('it returns Fail', () {
            expect(result, isA<Fail>());
          });

          test('it returns a failure message', () {
            expect(result.message, 'Failed to update task "Bar".');
          });

          test('it returns the exception as payload', () {
            expect((result as FailPack).payload, exception);
          });
        });
      });

      group('FocusTaskCommand', () {
        final task = createPersistedTask();
        final command = FocusTaskCommand(payload: task);

        group('when successful', () {
          setUp(() async {
            when(() => diligent.focus(task)).thenAnswer((_) async {});
            result = await commander.handle(command);
          });

          test('it returns Success', () {
            expect(result, isA<Success>());
          });

          test('it returns a success message', () {
            expect(
              result.message,
              'Task "${task.name}" was focused successfully.',
            );
          });
        });

        group('when unsuccessful', () {
          final exception = Exception('foo');
          setUp(() async {
            when(() => diligent.focus(task)).thenThrow(exception);
            result = await commander.handle(command);
          });

          test('it returns Fail', () {
            expect(result, isA<Fail>());
          });

          test('it returns a failure message', () {
            expect(result.message, 'Failed to focus task "Foo".');
          });

          test('it returns the exception as payload', () {
            expect((result as FailPack).payload, exception);
          });
        });
      });

      group('UnfocusTaskCommand', () {
        final task = createPersistedTask();
        final command = UnfocusTaskCommand(payload: task);

        group('when successful', () {
          setUp(() async {
            when(() => diligent.unfocus(task)).thenAnswer((_) async {});
            result = await commander.handle(command);
          });

          test('it returns Success', () {
            expect(result, isA<Success>());
          });

          test('it returns a success message', () {
            expect(
              result.message,
              'Task "${task.name}" was unfocused successfully.',
            );
          });
        });

        group('when unsuccessful', () {
          final exception = Exception('foo');
          setUp(() async {
            when(() => diligent.unfocus(task)).thenThrow(exception);
            result = await commander.handle(command);
          });

          test('it returns Fail', () {
            expect(result, isA<Fail>());
          });

          test('it returns a failure message', () {
            expect(result.message, 'Failed to unfocus task "Foo".');
          });

          test('it returns the exception as payload', () {
            expect((result as FailPack).payload, exception);
          });
        });
      });

      group('Unknown command', () {
        final command = UnknownCommand();
        setUp(() async {
          result = await commander.handle(command);
        });

        test('it returns Fail', () {
          expect(result, isA<Fail>());
        });

        test('it returns a failure message', () {
          expect(result.message, 'Unknown command: UnknownCommand');
        });
      });
    });
  });
}
