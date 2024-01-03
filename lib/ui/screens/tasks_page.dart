import 'package:flutter/material.dart';

import '../../models/new_task.dart';
import '../../models/task.dart';
import '../../services/diligent.dart';
import '../components/common_screen.dart';
import '../keys.dart';

class TasksPage extends StatefulWidget {
  final Diligent diligent;
  const TasksPage({super.key, required this.diligent});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  late List<Task> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    populateTasks();
  }

  Future<void> populateTasks() async {
    final root = await widget.diligent.findTask(1);
    // TODO: Find a way to guarantee root task is always present.
    if (root == null) {
      throw Exception('Root task not found');
    }
    final areas = await widget.diligent.getChildren(root);
    updateTasks(areas);
  }

  void updateTasks(List<Task> tasks) {
    setState(() {
      _tasks = tasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    final diligent = widget.diligent;
    return CommonScreen(
        title: 'Tasks',
        floatingActionButton: FloatingActionButton(
          key: addTaskFloatingButton,
          onPressed: () async {
            final newTask = await TaskDialog.open(context, NewTask());
            if (newTask is Task) {
              final currentTask = (await diligent.findTask(1))!;
              await diligent
                  .addTask(newTask.copyWith(parentId: currentTask.id));
              final tasks = await diligent.getChildren(currentTask);
              setState(() {
                _tasks = tasks;
              });
            }
          },
          tooltip: 'Add Task',
          child: const Icon(Icons.add),
        ),
        child: ReorderableListView.builder(
          key: tasksTaskList,
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
          onReorder: (oldIndex, newIndex) async {
            final task = _tasks[oldIndex];
            await diligent.moveTask(task, newIndex);
            final currentParent = (await diligent.findTask(task.parentId!))!;
            updateTasks(await diligent.getChildren(currentParent));
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
        key: addTaskTaskNameField,
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
          key: addTaskSaveButton,
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
