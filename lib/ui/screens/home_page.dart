import 'package:flutter/material.dart';

import '../../model/new_task.dart';
import '../../model/task.dart';
import '../components/common_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<Task> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = [];
  }

  @override
  Widget build(BuildContext context) {
    return CommonScreen(
        title: 'Diligence',
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final newTask = await TaskDialog.open(context, NewTask());
            if (newTask is Task) {
              setState(() {
                // objectBox.taskBox.put(newTask);
                // _tasks = objectBox.tasks();
              });
            }
          },
          tooltip: 'Add Task',
          child: const Icon(Icons.add),
        ),
        child: ReorderableListView.builder(
          itemBuilder: (context, index) {
            final task = _tasks[index];
            return CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              key: Key(task.id.toString()),
              title: Text(task.name),
              onChanged: (bool? done) {
                setState(() {
                  _tasks[index] = task.copyWith(done: done ?? false);
                  // objectBox.taskBox.put(task);
                  // _tasks = objectBox.tasks();
                });
              },
              value: task.done,
            );
          },
          itemCount: _tasks.length,
          onReorder: (oldIndex, newIndex) {
            //
          },
        ));
  }
}

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
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Enter task name'),
        initialValue: _task.name,
        onChanged: (str) {
          setState(() {
            // _task.name = str;
          });
        },
      ),
      actions: [
        TextButton(
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
