import 'package:diligence/models/reminders/reminder.dart';
import 'package:diligence/models/reminders/reminder_list.dart';
import 'package:flutter_test/flutter_test.dart';

List<int> reminderTaskIds(Iterable<Reminder> reminders) =>
    reminders.map((reminder) => reminder.taskId).toList();

void main() {
  final now = DateTime(2024, 4, 16);

  group('ReminderList', () {
    final reminder1 = Reminder(taskId: 1, remindAt: now);
    final reminder2 = Reminder(taskId: 2, remindAt: now);
    late ReminderList reminders;

    setUp(() {
      reminders = ReminderList([
        reminder1,
        reminder2,
      ]);
    });

    test('should be able to add Reminders', () {
      expect(reminderTaskIds(reminders), [1, 2]);
    });

    test('should be able to replace reminders through array access', () {
      final reminder3 = Reminder(taskId: 3, remindAt: now);
      reminders[1] = reminder3;
      expect(reminderTaskIds(reminders), [1, 3]);
      expect(reminders.added, contains(reminder3));
    });

    test('should prevent duplicates when adding', () {
      reminders.add(reminder2);
      expect(reminderTaskIds(reminders), [1, 2]);
    });

    test('should prevent duplicates when assigning through array access', () {
      final nowNewInstance = DateTime(2024, 4, 16);
      final basicallyReminder1 = Reminder(
        taskId: 1,
        remindAt: nowNewInstance,
      );
      reminders[1] = (basicallyReminder1);
      expect(reminderTaskIds(reminders), [1, 2]);
    });

    group('when a task is added', () {
      late Reminder reminder3;
      setUp(() {
        reminder3 = Reminder(
          taskId: 3,
          remindAt: now.add(const Duration(days: 3)),
        );
        reminders.add(reminder3);
      });

      test('should be able add items', () {
        expect(reminderTaskIds(reminders), [1, 2, 3]);
      });

      test('should be able to track additions after instantiation', () {
        expect(reminders.added, <Reminder>{reminder3});
      });

      test('should remove from added when removed', () {
        reminders.remove(reminder3);
        expect(reminders.added, <Reminder>{});
      });
    });

    group('when a reminder is removed', () {
      setUp(() {
        reminders.remove(reminder1);
      });

      test('should be able to track removals', () {
        expect(reminders.removed, contains(reminder1));
        expect(reminders, isNot(contains(reminder1)));
      });

      test('reminders that are added back are removed from removed set', () {
        // make sure it's the same datetime value but different instance
        final nowNewInstance = DateTime(2024, 4, 16);
        final basicallyReminder1 = Reminder(
          taskId: 1,
          remindAt: nowNewInstance,
        );
        reminders.add(basicallyReminder1);

        expect(reminders.removed, isNot(contains(reminder1)));
        expect(reminders, contains(reminder1));
      });
    });
  });
}
