import 'package:collection/collection.dart';

import '../tasks.dart';
import 'reminder.dart';

class ReminderList extends DelegatingList<Reminder> {
  final Set<Reminder> removed = {};
  final Set<Reminder> added = {};

  bool get isModified => removed.isNotEmpty || added.isNotEmpty;

  ReminderList([List<Reminder>? base]) : super(base ?? <Reminder>[]);

  @override
  bool remove(Object? value) {
    final successful = super.remove(value);
    if (successful && value is Reminder) {
      removed.add(value);
      if (added.contains(value)) {
        added.remove(value);
      }
    }
    return successful;
  }

  @override
  void add(Reminder value) {
    if (contains(value)) {
      return;
    }

    super.add(value);
    added.add(value);
    if (removed.contains(value)) {
      removed.remove(value);
    }
  }

  @override
  void operator []=(int index, Reminder value) {
    // This practically prevents duplicates when assigning through array access
    if (contains(value)) {
      return;
    }

    final removedItem = this[index];
    super[index] = value;

    if (removed.contains(removedItem)) {
      removed.remove(removedItem);
    }

    if (!added.contains(value)) {
      added.add(value);
    }
  }

  ReminderList remapToTask(PersistedTask task) {
    if (length == 0) {
      return this;
    }
    final taskId = first.taskId;

    // TODO: Investigate if we should throw because it is inapplicable
    if (every((r) => r.taskId != taskId)) {
      return this;
    }

    return ReminderList(map((r) => r.copyWith(taskId: task.id)).toList());
  }
}
