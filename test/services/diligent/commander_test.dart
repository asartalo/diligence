import 'package:diligence/models/commands/commands.dart';
import 'package:diligence/models/new_task.dart';
import 'package:diligence/models/persisted_task.dart';
import 'package:diligence/services/diligent.dart';
import 'package:diligence/services/diligent/diligent_commander.dart';
import 'package:diligence/utils/stub_clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ignore_for_file: no-empty-block
// ignore_for_file: avoid-redundant-async
// ignore_for_file: prefer-match-file-name

class MockDiligent extends Mock implements Diligent {}

class UnknownCommand extends Command {
  const UnknownCommand({required super.at});
}

void main() {
  group('DiligentCommander', () {
    late DiligentCommander commander;
    late Diligent diligent;
    final now = DateTime.now();
    final clock = StubClock(now);

    setUp(() async {
      diligent = MockDiligent();
      when(() => diligent.addReminders(any())).thenAnswer((_) async {});
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
        final newTask = NewTask(
          name: 'Foo',
          now: DateTime.now(),
        );
        final command = NewTaskCommand(task: newTask, at: clock.now());

        group('when successful', () {
          setUp(() async {
            final now = DateTime.now();
            when(() => diligent.addTask(newTask)).thenAnswer(
              (_) async {
                return createPersistedTask(now: now);
              },
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
        final command = DeleteTaskCommand(task: task, at: clock.now());

        group('when successful', () {
          setUp(() async {
            when(() => diligent.deleteTask(task)).thenAnswer((_) async {});
            result = await commander.handle(command);
          });

          test('it returns Success', () {
            expect(result, isA<Success>());
          });

          test('it returns a success message', () {
            expect(
              result.message,
              'Task "${task.name}" was deleted successfully.',
            );
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
        final task = originalTask.copyWith(
          name: 'Bar',
          now: now.add(const Duration(seconds: 1)),
        );
        final command = UpdateTaskCommand(task: task, at: now);

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
        final command = FocusTaskCommand(task: task, at: clock.now());

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
        final command = UnfocusTaskCommand(task: task, at: clock.now());

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
        final command = UnknownCommand(at: clock.now());
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
