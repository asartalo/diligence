import 'package:flutter/material.dart';

import '../../../models/task.dart';
import 'keys.dart' as keys;

class TaskDialog extends StatefulWidget {
  final Task task;
  const TaskDialog({super.key, required this.task});

  static Future<Task?> open(BuildContext context, Task task) {
    return showDialog(
      context: context,
      builder: (context) => TaskDialog(task: task),
    );
  }

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  late Task _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _task.id == 0 ? 'New Task' : 'Edit Task',
      ),
      content: TextFormField(
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
      actions: [
        TextButton(
          key: keys.saveTaskButton,
          onPressed: () => submit(),
          child: const Text('SAVE'),
        ),
      ],
    );
  }

  void submit() {
    Navigator.of(context).pop<Task>(_task);
  }
}
