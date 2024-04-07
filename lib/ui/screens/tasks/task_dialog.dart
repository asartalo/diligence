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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../models/commands/commands.dart';
import '../../../models/tasks.dart';
import '../../components/reveal_on_hover.dart';
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
        content: Container(
          constraints: const BoxConstraints(minWidth: 300),
          width: 400,
          child: Column(
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
              ),
              const SizedBox(height: 40),
              FocusTraversalGroup(
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
                            if (_task is PersistedTask) {
                              Navigator.of(context).pop<Command>(
                                DeleteTaskCommand(task: _task as PersistedTask),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFocusTask() {
    Navigator.of(context).pop<Command>(FocusTaskCommand(task: _task));
  }

  void submit() {
    late Command command;
    switch (_task) {
      case final NewTask t:
        command = NewTaskCommand(task: t);
      case final ModifiedTask t:
        command = UpdateTaskCommand(task: t);
      default:
        command = noOpCommand;
    }
    Navigator.of(context).pop<Command>(command);
  }
}
