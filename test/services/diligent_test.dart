import 'package:diligence/models/reminders/reminder.dart';
import 'package:diligence/models/reminders/reminder_list.dart';
import 'package:diligence/models/task.dart';
import 'package:diligence/services/diligent.dart';
import 'package:diligence/utils/stub_clock.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/error_matcher.dart';
import '../helpers/test_db.dart';

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
    late StubClock clock;

    setUpAll(() async {
      clock = StubClock();
      diligent = Diligent.forTests(db: testDb, clock: clock);
      await diligent.setUp();
    });

    tearDown(() async {
      await diligent.clearDataForTests();
    });

    group('#addTask()', () {
      group('when successful', () {
        late Task task;

        setUpAll(() async {
          task = await diligent.addTask(diligent.newTask(name: 'Foo'));
        });

        test('it returns the persisted task', () {
          expect(task.name, equals('Foo'));
        });

        test('it returns the persisted task with an id', () {
          expect(task.id, isNotNull);
        });

        test('it returns the persisted task with a uid', () {
          expect(task.uid, isNotNull);
        });

        test('it returns the persisted task with a createdAt', () {
          expect(task.createdAt, isNotNull);
        });

        test('it returns the persisted task with an updatedAt', () {
          expect(task.updatedAt, isNotNull);
        });
      });

      group('failure modes', () {
        test('it throws an error when the parent does not exist', () async {
          expect(
            () async => await diligent.addTask(
              diligent.newTask(name: 'Foo', parentId: 999),
            ),
            throwsA(
              matchesError<ArgumentError>('Parent with id 999 does not exist.'),
            ),
          );
        });

        test('it throws an error when the task name is empty', () async {
          expect(
            () async => await diligent.addTask(
              // ignore: avoid_redundant_argument_values
              diligent.newTask(name: ''),
            ),
            throwsA(
              matchesError<ArgumentError>('Task name must not be empty.'),
            ),
          );
        });
      });
    });

    group('#addTasks()', () {
      test('it adds multiple tasks', () async {
        final tasks = await diligent.addTasks([
          diligent.newTask(name: 'Foo'),
          diligent.newTask(name: 'Bar'),
        ]);
        expect(taskNames(tasks), equals(['Foo', 'Bar']));
      });

      test('it can add multiple tasks to a parent', () async {
        final parent = await diligent.addTask(diligent.newTask(name: 'Parent'));
        await diligent.addTasks([
          diligent.newTask(name: 'Foo', parentId: parent.id),
          diligent.newTask(name: 'Bar', parentId: parent.id),
        ]);
        final tasks = await diligent.getChildren(parent);
        expect(taskNames(tasks), equals(['Foo', 'Bar']));
      });

      test('it adds children at the end position by default', () async {
        final parent = await diligent.addTask(diligent.newTask(name: 'Parent'));
        await diligent.addTasks([
          diligent.newTask(name: 'First', parentId: parent.id),
        ]);
        await diligent.addTasks([
          diligent.newTask(name: 'Foo', parentId: parent.id),
          diligent.newTask(name: 'Bar', parentId: parent.id),
        ]);
        final tasks = await diligent.getChildren(parent);

        expect(taskNames(tasks), equals(['First', 'Foo', 'Bar']));
      });

      test('it can add children to a position when defined', () async {
        final parent = await diligent.addTask(diligent.newTask(name: 'Parent'));
        await diligent.addTasks([
          diligent.newTask(name: 'A', parentId: parent.id),
          diligent.newTask(name: 'D', parentId: parent.id),
          diligent.newTask(name: 'E', parentId: parent.id),
        ]);
        await diligent.addTasks(
          [
            diligent.newTask(name: 'B', parentId: parent.id),
            diligent.newTask(name: 'C', parentId: parent.id),
          ],
          position: 1,
        );
        final tasks = await diligent.getChildren(parent);

        expect(taskNames(tasks), equals(['A', 'B', 'C', 'D', 'E']));
      });

      group('failure modes', () {
        test('it throws an error when the parent does not exist', () async {
          expect(
            () async => await diligent.addTasks([
              diligent.newTask(name: 'Foo', parentId: 999),
            ]),
            throwsA(
              matchesError<ArgumentError>('Parent with id 999 does not exist.'),
            ),
          );
        });

        // TODO: Think of how we could remove this restriction in the future
        test(
          'it restricts to only adding tasks with the same parents at a time',
          () async {
            final parent1 =
                await diligent.addTask(diligent.newTask(name: 'Parent 1'));
            final parent2 =
                await diligent.addTask(diligent.newTask(name: 'Parent 2'));
            expect(
              () async => await diligent.addTasks([
                diligent.newTask(name: 'Foo', parentId: parent1.id),
                diligent.newTask(name: 'Bar', parentId: parent2.id),
              ]),
              throwsA(
                matchesError<ArgumentError>(
                  'All tasks must have the same parent.',
                ),
              ),
            );
          },
        );
      });
    });

    group('#updateTask()', () {
      late Task task;
      late Task updatedTask;

      setUpAll(() async {
        task = await diligent.addTask(diligent.newTask(name: 'Foo'));
        clock.advance(const Duration(seconds: 1));
        updatedTask = await diligent.updateTask(
          task.copyWith(name: 'Bar', now: clock.now()),
        );
      });

      test('it updates the task', () {
        expect(updatedTask.name, equals('Bar'));
      });

      test('it updates the task with an updatedAt', () {
        expect(updatedTask.updatedAt, isNot(task.updatedAt));
      });

      test('it does not update the uid', () {
        expect(updatedTask.uid, equals(task.uid));
      });

      test('it does not update the createdAt', () {
        expect(updatedTask.createdAt, equals(task.createdAt));
      });
    });

    group('#subtreeFlat()', () {
      late Map<String, Task> setupResult;

      setUp(() async {
        setupResult = await testTreeSetup(diligent);
      });

      test('it returns subtree as a flat list', () async {
        final aTask = setupResult['A'];
        if (aTask == null) {
          fail('Unexpected result. testTreeSetup() did not work.');
        }
        final TaskNodeList taskNodes = await diligent.subtreeFlat(aTask.id);
        final nameList = <String>[];
        for (final taskNode in taskNodes) {
          nameList.add(taskNode.task.name);
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

    group('#leaves()', () {
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
    });

    group('#expandedDescendantsTree()', () {
      late Map<String, Task> setupResult;

      setUp(() async {
        setupResult = await testTreeSetup(diligent);
      });

      test(
        'it returns subtree starting from descendants including of root',
        () async {
          final rootTask = setupResult['Root'];
          if (rootTask == null) {
            fail('Unexpected result. testTreeSetup() did not work.');
          }
          final TaskNodeList taskNodes =
              await diligent.expandedDescendantsTree(rootTask);
          final nameList = <String>[];
          for (final taskNode in taskNodes) {
            nameList.add(taskNode.task.name);
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
        },
      );
    });

    group('#ancestors()', () {
      late Map<String, Task> setupResult;

      setUp(() async {
        setupResult = await testTreeSetup(Diligent.forTests(db: testDb));
      });

      test('it returns all ancestors of a task except root', () async {
        final task = setupResult['B2i - leaf']!;
        final ancestors = await diligent.ancestors(task);
        expect(
          taskNames(ancestors),
          equals(['Root', 'B', 'B2']),
        );
      });
    });

    group('Basic CRUD', () {
      test('can create a root task', () async {
        final task = await diligent.addTask(diligent.newTask(name: 'Root'));
        expect(task.name, equals('Root'));
      });

      test('persists task', () async {
        final id = (await diligent.addTask(diligent.newTask(
          name: 'Foo',
          details: 'Bar',
        )))
            .id;
        final task = await diligent.findTask(id);
        expect(task!.name, equals('Foo'));
        expect(task.details, equals('Bar'));
      });

      test('it can update a task', () async {
        final task = await diligent.addTask(diligent.newTask(name: 'Foo'));
        await diligent.updateTask(task.copyWith(name: 'Bar', now: clock.now()));
        final updatedTask = await diligent.findTask(task.id);
        expect(updatedTask?.name, equals('Bar'));
      });

      test('increments childrenCount when a child task is added', () async {
        final parentTask =
            await diligent.addTask(diligent.newTask(name: 'Root'));
        await diligent
            .addTask(diligent.newTask(name: 'Foo', parent: parentTask));
        final taskNodes = await diligent.subtreeFlat(parentTask.id);
        expect(taskNodes.first.childrenCount, equals(1));
      });

      test('can delete a task', () async {
        final task = await diligent.addTask(diligent.newTask(name: 'Foo'));
        await diligent.deleteTask(task);
        expect(await diligent.findTask(task.id), isNull);
      });

      test('decrements childrenCount when a child task is deleted', () async {
        final parentTask =
            await diligent.addTask(diligent.newTask(name: 'Root'));
        final task = await diligent.addTask(
          diligent.newTask(name: 'Foo', parent: parentTask),
        );
        await diligent.deleteTask(task);
        final taskNodes = await diligent.subtreeFlat(parentTask.id);
        expect(taskNodes.first.childrenCount, equals(0));
      });

      test('can find task by name', () async {
        await diligent.addTask(diligent.newTask(name: 'Root'));
        final task = await diligent.findTaskByName('root');
        expect(task?.name, equals('Root'));
      });
    });

    group('Hierarchy', () {
      late Task parentTask;

      setUp(() async {
        parentTask = await diligent.addTask(diligent.newTask(name: 'Root'));
      });

      test('node with no children has 0 childCount', () async {
        final taskNodes = await diligent.subtreeFlat(parentTask.id);
        expect(taskNodes.first.childrenCount, equals(0));
      });

      test('it can set a parent to a task', () async {
        final task = await diligent
            .addTask(diligent.newTask(name: 'Foo', parentId: parentTask.id));
        final children = await diligent.getChildren(parentTask);
        expect(children.first.name, equals(task.name));
        expect((await diligent.getParent(task))!.name, equals(parentTask.name));
      });

      test('it appends new children to parent', () async {
        final task1 = await diligent.addTask(
          diligent.newTask(name: 'Foo', parent: parentTask),
        );
        final task2 = await diligent.addTask(
          diligent.newTask(name: 'Bar', parent: parentTask),
        );
        expect(
          taskNames(await diligent.getChildren(parentTask)),
          equals(taskNames([task1, task2])),
        );
      });

      test('it can insert child to a position', () async {
        final task1 = await diligent.addTask(
          diligent.newTask(name: 'Foo', parent: parentTask),
        );
        final task2 = await diligent.addTask(
          diligent.newTask(name: 'Bar', parent: parentTask),
          position: 0,
        );
        expect(
          taskNames(await diligent.getChildren(parentTask)),
          equals(taskNames([task2, task1])),
        );
      });
    });

    group('Moving Tasks', () {
      group('Within Siblings', () {
        late Task parentTask;

        setUp(() async {
          parentTask = await diligent.addTask(diligent.newTask(name: 'Root'));
          for (final taskName in ['A', 'B', 'C', 'D', 'E']) {
            await diligent
                .addTask(diligent.newTask(name: taskName, parent: parentTask));
          }
        });

        test('it can insert new child at the beginning', () async {
          await diligent.addTask(
            diligent.newTask(name: 'Bar', parent: parentTask),
            position: 0,
          );
          final children = await diligent.getChildren(parentTask);
          expect(taskNames(children), equals(['Bar', 'A', 'B', 'C', 'D', 'E']));
        });

        test('it can move task up', () async {
          final task = (await diligent.findTaskByName('D'))!;
          await diligent.moveTask(task, 1);
          final children = await diligent.getChildren(parentTask);
          expect(
            taskNames(children),
            equals(['A', 'D', 'B', 'C', 'E']),
          );
        });

        test('it can move task down', () async {
          final task = (await diligent.findTaskByName('B'))!;
          await diligent.moveTask(task, 3);
          final children = await diligent.getChildren(parentTask);
          expect(
            taskNames(children),
            equals(['A', 'C', 'D', 'B', 'E']),
          );
        });

        test('it limits movement to last position', () async {
          final task = (await diligent.findTaskByName('B'))!;
          await diligent.moveTask(task, 10);
          final children = await diligent.getChildren(parentTask);
          expect(
            taskNames(children),
            equals(['A', 'C', 'D', 'E', 'B']),
          );
        });

        test('it limits movement to first position', () async {
          final task = (await diligent.findTaskByName('B'))!;
          await diligent.moveTask(task, -3);
          final children = await diligent.getChildren(parentTask);
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
          final newSiblings = await diligent.getChildren(newParent);
          expect(
            taskNames(newSiblings),
            equals(['B2', 'A1i - leaf', 'A1ii - leaf', 'A1iii - leaf']),
          );
          final oldSiblings = await diligent.getChildren(oldParent);
          expect(
            taskNames(oldSiblings),
            equals(['B1 - leaf', 'B3 - leaf']),
          );
        });

        test(
          'it can move task to a different node to a different position',
          () async {
            final task = setupResult['B2']!;
            final newParent = setupResult['A1']!;
            await diligent.moveTask(task, 2, parent: newParent);
            final newSiblings = await diligent.getChildren(newParent);
            expect(
              taskNames(newSiblings),
              equals(['A1i - leaf', 'A1ii - leaf', 'B2', 'A1iii - leaf']),
            );
          },
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
          taskNames(tasks.map((taskNode) => taskNode.task).toList()),
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

      test('it can get number of tasks on the queue', () async {
        await focusItems(['A1i - leaf', 'A2 - leaf', 'B1 - leaf']);
        final count = await diligent.getFocusedCount();
        expect(count, 3);
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
        'when adding an ancestor task, it adds its descendant leaf tasks that are not doneu to the queue',
        () async {
          await diligent.focus(setupResult['A1i - leaf']!);
          final task = setupResult['B2ii - leaf']!;
          await diligent.updateTask(task.markDone(clock.now()));
          await diligent.focus(setupResult['B']!);
          expect(
            taskNames(await diligent.focusQueue()),
            equals([
              'B1 - leaf',
              'B2i - leaf',
              'B2iii - leaf',
              'B3 - leaf',
              'A1i - leaf',
            ]),
          );
        },
      );

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
        },
      );

      test(
        'when a task is deleted, it is also unfocused',
        () async {
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
        },
      );

      test(
        'when a task is marked as done, it is removed from the queue',
        () async {
          final task = setupResult['C - leaf']!;
          await diligent.focus(setupResult['A1i - leaf']!);
          await diligent.focus(task);
          final now = clock.now();
          await diligent.updateTask(task.markDone(now));
          expect(
            taskNames(await diligent.focusQueue()),
            equals([
              'A1i - leaf',
            ]),
          );
        },
      );

      test(
        'when a task is focused again it is moved to the top of the queue',
        () async {
          final task = setupResult['C - leaf']!;
          await diligent.focus(task);
          await diligent.focus(setupResult['A1i - leaf']!);
          await diligent.focus(task);
          expect(
            taskNames(await diligent.focusQueue()),
            equals([
              'C - leaf',
              'A1i - leaf',
            ]),
          );
        },
      );

      test('focusQueue can limit result', () async {
        await focusItems(['B', 'C - leaf']);
        expect(
          taskNames(await diligent.focusQueue(limit: 3)),
          equals([
            'C - leaf',
            'B1 - leaf',
            'B2i - leaf',
          ]),
        );
      });

      test('a task can be reprioretized in the focus queue', () async {
        await focusItems(['B', 'C - leaf']);
        final task = setupResult['B2i - leaf']!;
        await diligent.reprioritizeInFocusQueue(task, 1);
        expect(
          taskNames(await diligent.focusQueue()),
          equals([
            'C - leaf',
            'B2i - leaf',
            'B1 - leaf',
            'B2ii - leaf',
            'B2iii - leaf',
            'B3 - leaf',
          ]),
        );
      });

      test(
        'when tasks are added to a focused task, the children are added to the queue',
        () async {
          final parent = setupResult['A1i - leaf']!;
          await diligent.focus(parent);
          await diligent.addTasks([
            diligent.newTask(name: 'New Task 1', parent: parent),
            diligent.newTask(name: 'New Task 2', parent: parent),
          ]);
          expect(
            taskNames(await diligent.focusQueue()),
            equals([
              'New Task 1',
              'New Task 2',
            ]),
          );
        },
      );
    });

    group('Done Logic in Tree Structure', () {
      late Map<String, Task> setupResult;

      setUp(() async {
        setupResult = await testTreeSetup(diligent);
      });

      Future<void> markNodesDone(List<String> taskNames) async {
        for (final taskName in taskNames) {
          await diligent
              .updateTask(setupResult[taskName]!.markDone(clock.now()));
        }
      }

      test(
        'marking a single leaf node as done while its siblings are not done does not affect ancestors',
        () async {
          final task = setupResult['A1i - leaf']!;
          await diligent.updateTask(task.markDone(clock.now()));
          final a1 = await diligent.findTask(setupResult['A1']!.id);
          final a = await diligent.findTask(setupResult['A']!.id);
          expect(a1!.done, isFalse);
          expect(a!.done, isFalse);
        },
      );

      test(
        'marking a single leaf node when its siblings are all done marks its parent as done',
        () async {
          await markNodesDone([
            'A1i - leaf',
            'A1ii - leaf',
            'A1iii - leaf',
          ]);

          final a1 = await diligent.findTask(setupResult['A1']!.id);
          expect(a1!.done, isTrue);
        },
      );

      test(
        'marking a single leaf node when its siblings and aunts/uncles are all done marks its parent and grandparent as done',
        () async {
          await markNodesDone([
            'A1i - leaf',
            'A1ii - leaf',
            'A1iii - leaf',
            'A2 - leaf',
            'A3 - leaf',
          ]);
          final a = await diligent.findTask(setupResult['A']!.id);
          expect(a!.done, isTrue);
        },
      );

      test(
        'marking a single leaf node when its siblings are all done but not all aunts/uncles only marks its parent as done',
        () async {
          await markNodesDone([
            'A1i - leaf',
            'A1ii - leaf',
            'A1iii - leaf',
            'A2 - leaf',
          ]);
          final a = await diligent.findTask(setupResult['A']!.id);
          final a1 = await diligent.findTask(setupResult['A1']!.id);
          expect(a!.done, isFalse);
          expect(a1!.done, isTrue);
        },
      );

      test(
        'marking a single leaf node not done when its parent is done marks its parent as not done',
        () async {
          await diligent.updateTask(setupResult['A1']!.markDone(clock.now()));
          final updatedA1i =
              await diligent.findTask(setupResult['A1i - leaf']!.id);
          await diligent.updateTask(updatedA1i!.markNotDone(clock.now()));
          final a1 = await diligent.findTask(setupResult['A1']!.id);
          expect(a1!.done, isFalse);
        },
      );

      test(
        'marking a single leaf node not done when its ancestors are done marks them as not done too',
        () async {
          await diligent.updateTask(setupResult['A']!.markDone(clock.now()));
          final updatedA1i =
              await diligent.findTask(setupResult['A1i - leaf']!.id);
          await diligent.updateTask(updatedA1i!.markNotDone(clock.now()));
          final ancestors = ['A1', 'A'];
          for (final ancestor in ancestors) {
            final task = await diligent.findTask(setupResult[ancestor]!.id);
            expect(task!.done, isFalse);
          }
        },
      );

      test(
        'marking a parent node as done marks all of its children as done',
        () async {
          await diligent.updateTask(setupResult['A1']!.markDone(clock.now()));
          final names = ['A1i - leaf', 'A1ii - leaf', 'A1iii - leaf'];
          for (final name in names) {
            final task = await diligent.findTask(setupResult[name]!.id);
            expect(task!.done, isTrue);
          }
        },
      );

      test(
        'marking an ancestor node as done marks all of its descendants as done',
        () async {
          await diligent.updateTask(setupResult['A']!.markDone(clock.now()));
          final names = [
            'A1i - leaf',
            'A1ii - leaf',
            'A1iii - leaf',
            'A2 - leaf',
            'A3 - leaf',
          ];
          for (final name in names) {
            final task = await diligent.findTask(setupResult[name]!.id);
            expect(task!.done, isTrue);
          }
        },
      );

      test(
        'marking a parent node as not done marks all of its children as not done',
        () async {
          final names = [
            'A1i - leaf',
            'A1ii - leaf',
            'A1iii - leaf',
          ];
          await markNodesDone(names);
          final updatedA1 = await diligent.findTask(setupResult['A1']!.id);
          await diligent.updateTask(updatedA1!.markNotDone(clock.now()));
          for (final name in names) {
            final task = await diligent.findTask(setupResult[name]!.id);
            expect(task!.done, isFalse);
          }
        },
      );

      test(
        'marking an ancestor node as done removes child nodes that are focused',
        () async {
          await diligent.focus(setupResult['A1i - leaf']!);
          await markNodesDone(['A']);
          final updatedA1 = await diligent.findTask(setupResult['A1']!.id);
          await diligent.updateTask(updatedA1!.markNotDone(clock.now()));
          final queue =
              (await diligent.focusQueue()).map((task) => task.name).toList();
          expect(queue, isNot(contains('A1i - leaf')));
        },
      );

      test(
        'adding a child task to a done node marks parent and ancestors as not done',
        () async {
          await markNodesDone(['A']);
          await diligent.addTask(
            diligent.newTask(name: 'New Task', parent: setupResult['A1']),
          );
          final toCheck = ['A1', 'A'];
          for (final name in toCheck) {
            final task = await diligent.findTask(setupResult[name]!.id);
            expect(task!.done, isFalse);
          }
        },
      );

      test(
        'deleting a not done child task when all siblings are done marks parent as and possibly ancestors done',
        () async {
          await markNodesDone(['A']);
          final a1iLeaf =
              await diligent.findTask(setupResult['A1i - leaf']!.id);
          expect(a1iLeaf!.done, isTrue);
          await diligent.updateTask(a1iLeaf.markNotDone(clock.now()));

          final toCheck = ['A1', 'A'];
          for (final name in toCheck) {
            final task = (await diligent.findTask(setupResult[name]!.id))!;
            expect(task.done, isFalse);
          }
          await diligent.deleteTask(setupResult['A1i - leaf']!);
          for (final name in toCheck) {
            final task = await diligent.findTask(setupResult[name]!.id);
            expect(task!.done, isTrue);
          }
        },
      );

      test(
        'moving a not done task to a done parent marks the new parent as not done',
        () async {
          await markNodesDone(['B2']);
          final b2Id = setupResult['B2']!.id;
          expect((await diligent.findTask(b2Id))!.done, isTrue);

          final a1iLeaf =
              await diligent.findTask(setupResult['A1i - leaf']!.id);
          expect(a1iLeaf!.done, isFalse);

          await diligent.moveTask(a1iLeaf, 0, parent: setupResult['B2']);
          final task = (await diligent.findTask(b2Id))!;
          expect(task.done, isFalse);

          // Make sure all other children are still done
          final toCheck = ['B2i - leaf', 'B2ii - leaf', 'B2iii - leaf'];
          for (final name in toCheck) {
            final task = (await diligent.findTask(setupResult[name]!.id))!;
            expect(task.done, isTrue);
          }
        },
      );

      test(
        'moving a not done task that has all siblings done to another parent marks that parent as done',
        () async {
          await markNodesDone(['B2i - leaf', 'B2iii - leaf']);
          final b2ii =
              (await diligent.findTask(setupResult['B2ii - leaf']!.id))!;

          await diligent.moveTask(b2ii, 0, parent: setupResult['A1']);

          final toCheck = ['B2i - leaf', 'B2iii - leaf', 'B2'];
          for (final name in toCheck) {
            final task = (await diligent.findTask(setupResult[name]!.id))!;
            expect(task.done, isTrue);
          }
        },
      );
    });

    group('Deadlines', () {
      test('task does not have deadlines by default', () async {
        final task = await diligent.addTask(diligent.newTask(name: 'Foo'));
        expect(task.deadlineAt, isNull);
      });

      test('task can have a deadline', () async {
        final deadline = diligent.clock
            .now()
            .add(const Duration(days: 2))
            .copyWith(microsecond: 0);
        final task = await diligent.addTask(diligent.newTask(
          name: 'Foo',
          deadlineAt: deadline,
        ));
        expect(task.deadlineAt, equals(deadline));
      });
    });

    group('Reminders', () {
      late Task task;
      late DateTime now;
      late DateTime tomorrow;
      late Reminder reminder;

      setUp(() async {
        task = await diligent.addTask(diligent.newTask(name: 'Foo'));
        now = diligent.clock.now();
        tomorrow = now.add(const Duration(days: 1));
        reminder = Reminder(taskId: task.id, remindAt: tomorrow);
        await diligent.addReminders([reminder]);
      });

      test('a reminder can be set to a task', () async {
        final reminders = await diligent.getNextReminders(tomorrow);

        expect(reminders.first.taskId, equals(task.id));
      });

      test('a reminder is not dismissed by default', () async {
        expect(reminder.dismissed, isFalse);
      });

      test('multiple reminders can be set to a task', () async {
        final dayAfterTom = tomorrow.add(const Duration(days: 1));
        await diligent.addReminders([
          Reminder(taskId: task.id, remindAt: dayAfterTom),
        ]);
        final reminders = await diligent.getRemindersForTask(task);

        expect(uniques(reminders, (reminder) => reminder.taskId), [task.id]);
        expect(
          reminders.map((reminder) => reminder.remindAt.millisecondsSinceEpoch),
          [
            tomorrow.millisecondsSinceEpoch,
            dayAfterTom.millisecondsSinceEpoch,
          ],
        );
      });

      test('a reminder can be dismissed', () async {
        clock.advance(const Duration(days: 1));
        await diligent.dismissReminder(reminder);
        final reminders = await diligent.getRemindersForTask(task);

        expect(reminders.first.dismissed, isTrue);
      });

      test(
        'a reminder cannnot be dismissed if it is not past remindAt yet',
        () async {
          expect(
            () async {
              await diligent.dismissReminder(reminder);
            },
            throwsA(
              matchesError<ReminderError>(
                'Cannot dismiss a reminder before it is due.',
              ),
            ),
          );
          final reminders = await diligent.getRemindersForTask(task);

          expect(reminders.first.dismissed, isFalse);
        },
      );

      test('reminders can be deleted', () async {
        final dayAfterTom = tomorrow.add(const Duration(days: 1));
        final reminder2 = Reminder(taskId: task.id, remindAt: dayAfterTom);
        await diligent.addReminders([reminder2]);
        await diligent.deleteReminders([reminder, reminder2]);
        final reminders = await diligent.getRemindersForTask(task);

        expect(reminders, isEmpty);
      });

      test('reminders are part of the task pack', () async {
        final pack = await diligent.getTaskPackById(task.id);
        expect(pack!.reminders, ReminderList([reminder]));
      });
    });
  });
}

List<T> uniques<T, F>(List<F> list, T Function(F) mapper) {
  final result = <T>{};
  for (final item in list) {
    result.add(mapper(item));
  }
  return result.toList();
}

class _Tts {
  final String name;
  final String? parent;
  final bool expanded;
  final int? position;

  const _Tts(this.name, {this.parent, this.expanded = false, this.position});
}

Future<Task> _setupTestTask(
  Diligent diligent,
  _Tts tts,
) async {
  final parentTask =
      tts.parent != null ? await diligent.findTaskByName(tts.parent!) : null;
  final task = await diligent.addTask(
    diligent.newTask(
      name: tts.name,
      parent: parentTask,
      expanded: tts.expanded,
    ),
    position: tts.position,
  );
  return task;
}

// The following test tree represents the following structure:
//
// Root
// - A
//   - A1
//    - A1i - leaf
//    - A1ii - leaf
//    - A1iii - leaf
//   - A2 - leaf
//   - A3 - leaf
// - B
//   - B1 - leaf
//   - B2
//     - B2i - leaf
//     - B2ii - leaf
//     - B2iii - leaf
//   - B3 - leaf
// - C - leaf
List<_Tts> _testTree = const [
  _Tts('Root'),
  _Tts('A', parent: 'Root', expanded: true),
  _Tts('A1', parent: 'A'),
  _Tts('A2 - leaf', parent: 'A'),
  _Tts('A1ii - leaf', parent: 'A1'),
  _Tts('A3 - leaf', parent: 'A'),
  _Tts('A1iii - leaf', parent: 'A1'),
  _Tts('A1i - leaf', parent: 'A1', position: 0),
  _Tts('C - leaf', parent: 'Root'),
  _Tts('B', parent: 'root', expanded: true, position: 1),
  _Tts('B1 - leaf', parent: 'B', expanded: true),
  _Tts('B2', parent: 'B'),
  _Tts('B2i - leaf', parent: 'B2'),
  _Tts('B2ii - leaf', parent: 'B2'),
  _Tts('B3 - leaf', parent: 'B'),
  _Tts('B2iii - leaf', parent: 'B2'),
];

Future<Map<String, Task>> testTreeSetup(Diligent diligent) async {
  final Map<String, Task> result = {};
  for (final tts in _testTree) {
    result[tts.name] = await _setupTestTask(diligent, tts);
  }
  return result;
}
