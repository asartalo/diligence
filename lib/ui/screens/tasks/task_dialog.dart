// Diligence - A Task Management App
//
// Copyright (C) 2024 Wayne Duran <asartalo@gmail.com>
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// this program. If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';

import '../../../models/commands/commands.dart';
import '../../../models/reminders/reminder_list.dart';
import '../../../models/task_pack.dart';
import '../../../models/tasks.dart';
import '../../../utils/clock.dart';
import '../../../utils/i18n.dart';
import '../../components/reveal_on_hover.dart';
import '../../di/with_clock.dart';
import 'keys.dart' as keys;
import 'reminder_field.dart';

class TaskDialog extends StatefulWidget {
  final TaskPack pack;
  final Clock clock;

  const TaskDialog({super.key, required this.pack, required this.clock});

  static Future<Command?> open(
    BuildContext context, {
    required TaskPack pack,
    required Clock clock,
  }) {
    return showDialog<Command>(
      context: context,
      builder: (context) => TaskDialog(pack: pack, clock: clock),
    );
  }

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  late TaskPack pack;
  Task get task => pack.task;
  ReminderList get reminders => pack.reminders;
  Clock get clock => widget.clock;
  bool _showReminderFields = false;

  @override
  void initState() {
    super.initState();
    pack = widget.pack;
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);

    return Theme(
      data: currentTheme.copyWith(
        visualDensity: VisualDensity.standard,
      ),
      child: AlertDialog(
        title: Text(
          task.id == 0 ? 'New Task' : 'Edit Task',
        ),
        // backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        content: Container(
          constraints: const BoxConstraints(minWidth: 300),
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              nameField(),
              detailsField(),
              remindersSection(),
              const SizedBox(height: 40),
              actionsRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget nameField() {
    return TextFormField(
      key: keys.taskNameField,
      autofocus: true,
      decoration: const InputDecoration(hintText: 'Enter task name'),
      initialValue: task.name,
      onChanged: (str) {
        setState(() {
          pack = pack.updateTask(task.copyWith(name: str, now: clock.now()));
        });
      },
    );
  }

  Widget detailsField() {
    return TextFormField(
      key: keys.taskDetailsField,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      decoration: const InputDecoration(labelText: 'Details'),
      initialValue: task.details,
      onChanged: (str) {
        setState(() {
          pack = pack.updateTask(task.copyWith(details: str, now: clock.now()));
        });
      },
    );
  }

  Widget remindersSection() {
    return Column(
      key: keys.remindersSection,
      children: [
        const SizedBox(height: 20),
        ...remindersAdded(),
        _showReminderFields
            ? reminderField()
            : TextButton(
                key: keys.addReminderButton,
                child: const Text('+ Add Reminder'),
                onPressed: () {
                  setState(() {
                    _showReminderFields = !_showReminderFields;
                  });
                },
              ),
      ],
    );
  }

  List<Widget> remindersAdded() {
    return reminders.map((reminder) {
      return ListTile(
        title: Text(
          dateTimeFormat.format(reminder.remindAt),
        ),
        trailing: IconButton(
          key: keys.reminderDeleteButton,
          icon: const Icon(Icons.delete),
          onPressed: () {
            setState(() {
              reminders.remove(reminder);
            });
          },
        ),
      );
    }).toList();
  }

  Widget reminderField() {
    return WithClock(
      builder: (clock, context) {
        return ReminderField(
          task: task,
          clock: clock,
          onAddReminder: (reminder) {
            setState(() {
              reminders.add(reminder);
              _showReminderFields = false;
            });
          },
        );
      },
    );
  }

  Widget actionsRow() {
    // This widget ensures that the tab navigation focuses on the save button
    // first before the other actions.
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Row(
        children: [
          RevealOnHover(
            child: FocusTraversalOrder(
              order: const NumericFocusOrder(3),
              child: TextButton(
                key: keys.deleteTaskButton,
                child: const Text('DELETE'),
                onPressed: () {
                  if (task is PersistedTask) {
                    Navigator.of(context).pop<Command>(
                      DeleteTaskCommand(
                        task: task as PersistedTask,
                        at: clock.now(),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          const Spacer(),
          FocusTraversalOrder(
            order: const NumericFocusOrder(2),
            child: FilledButton(
              key: keys.focusTaskButton,
              onPressed: _handleFocusTask,
              child: const Text('FOCUS'),
            ),
          ),
          const SizedBox(width: 5),
          FocusTraversalOrder(
            order: const NumericFocusOrder(1),
            child: FilledButton(
              key: keys.saveTaskButton,
              onPressed: () => submit(),
              child: const Text('SAVE'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleFocusTask() {
    Navigator.of(context).pop<Command>(FocusTaskCommand(
      task: task,
      at: clock.now(),
    ));
  }

  void submit() {
    late Command command;
    final t = pack.task;
    if (t is NewTask) {
      command = NewTaskCommand(
        task: t,
        reminders: reminders,
        at: clock.now(),
      );
    } else if (pack.isModified) {
      command = UpdateTaskCommand(
        task: t,
        reminders: reminders,
        at: clock.now(),
      );
    } else {
      command = NoOpCommand(at: clock.now());
    }
    Navigator.of(context).pop<Command>(command);
  }
}
