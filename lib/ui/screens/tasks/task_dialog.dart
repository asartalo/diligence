import 'package:flutter/material.dart';

import '../../../models/commands/commands.dart';
import '../../../models/commands/focus_task_command.dart';
import '../../../models/decorated_task.dart';
import '../../../models/new_task.dart';
import '../../../models/provided_task.dart';
import '../../../models/task.dart';
import 'keys.dart' as keys;

class TaskDialog extends StatefulWidget {
  final Task task;
  const TaskDialog({super.key, required this.task});

  static Future<Command?> open(BuildContext context, Task task) {
    return showDialog<Command>(
      context: context,
      builder: (context) => TaskDialog(task: task),
    );
  }

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  late Task _task;

  Task get _trueTask =>
      (_task is DecoratedTask) ? (_task as DecoratedTask).task : _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
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
          _task.id == 0 ? 'New Task' : 'Edit Task',
        ),
        // backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              key: keys.taskNameField,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Enter task name'),
              initialValue: _task.name,
              onChanged: (str) {
                setState(() {
                  _task = _task.copyWith(name: str);
                });
              },
            ),
            TextFormField(
              key: keys.taskDetailsField,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: const InputDecoration(labelText: 'Details'),
              initialValue: _task.details,
              onChanged: (str) {
                setState(() {
                  _task = _task.copyWith(details: str);
                });
              },
            )
          ],
        ),
        actions: [
          TextButton(
            key: keys.deleteTaskButton,
            onPressed: () {
              if (_trueTask is ProvidedTask) {
                Navigator.of(context).pop<Command>(
                  DeleteTaskCommand(payload: _trueTask as ProvidedTask),
                );
              }
            },
            child: const Text('DELETE'),
          ),
          FilledButton(
            key: keys.focusTaskButton,
            onPressed: _handleFocusTask,
            child: const Text('FOCUS'),
          ),
          FilledButton(
            key: keys.saveTaskButton,
            onPressed: () => submit(),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  void _handleFocusTask() {
    Navigator.of(context).pop<Command>(FocusTaskCommand(payload: _trueTask));
  }

  void submit() {
    late Command command;
    switch (_trueTask) {
      case final NewTask t:
        command = NewTaskCommand(payload: t);
      case final ProvidedTask t:
        command = UpdateTaskCommand(payload: t);
      default:
        command = noOpCommand;
    }
    Navigator.of(context).pop<Command>(command);
  }
}