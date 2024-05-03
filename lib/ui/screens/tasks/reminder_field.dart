import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';

import '../../../models/reminders/reminder.dart';
import '../../../models/task.dart';
import '../../../utils/clock.dart';
import 'keys.dart' as keys;

typedef AddReminderCallback = void Function(Reminder reminder);

class ReminderField extends StatefulWidget {
  final AddReminderCallback onAddReminder;
  final Task task;
  final Clock clock;
  const ReminderField({
    super.key,
    required this.onAddReminder,
    required this.task,
    required this.clock,
  });

  @override
  State<ReminderField> createState() => _ReminderFieldState();
}

class _ReminderFieldState extends State<ReminderField> {
  late Reminder? _reminder;
  late DateTime _now;
  late DateTime _tomorrow;

  @override
  void initState() {
    super.initState();
    _now = widget.clock.now();
    _tomorrow = _now.add(const Duration(days: 1));
    // _reminder = Reminder(taskId: widget.task.id, remindAt: _tomorrow);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DateTimeFormField(
            key: keys.reminderDateField,
            decoration: const InputDecoration(
              labelText: 'Set a Reminder',
              hintText: 'Select a date and time',
            ),
            firstDate: _now,
            initialPickerDateTime: _tomorrow,
            onChanged: (remindAt) {
              if (remindAt == null) {
                return;
              }
              setState(() {
                _reminder = Reminder(
                  remindAt: remindAt,
                  taskId: widget.task.id,
                );
              });
            },
          ),
        ),
        const SizedBox(width: 10.0),
        IconButton(
          key: keys.reminderAddButton,
          onPressed: () {
            if (_reminder is Reminder) {
              widget.onAddReminder(_reminder!);
            }
          },
          icon: const Icon(Icons.check),
        ),
      ],
    );
  }
}
