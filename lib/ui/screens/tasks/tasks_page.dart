import 'package:flutter/material.dart';

import '../../../models/new_task.dart';
import '../../../models/task.dart';
import '../../../services/diligent.dart';
import '../../components/common_screen.dart';
import 'keys.dart' as keys;
import 'task_dialog.dart';
import 'task_tree.dart';

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
        key: keys.addTaskFloatingButton,
        onPressed: () async {
          final newTask = await TaskDialog.open(context, NewTask());
          if (newTask is Task) {
            final currentTask = (await diligent.findTask(1))!;
            await diligent.addTask(newTask.copyWith(parentId: currentTask.id));
            final tasks = await diligent.getChildren(currentTask);
            setState(() {
              _tasks = tasks;
            });
          }
        },
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
      child: TaskTree(
        tasks: _tasks,
        onUpdateTask: (task, index) {
          setState(() {
            _tasks[index] = task;
          });
        },
        onReorder: (oldIndex, newIndex) async {
          final task = _tasks.removeAt(oldIndex);
          setState(() {
            // Let's move the element inline so we don't see a flicker
            _tasks.insert(newIndex, task);
          });
          await diligent.moveTask(task, newIndex);
          final currentParent = (await diligent.findTask(task.parentId!))!;
          updateTasks(await diligent.getChildren(currentParent));
        },
      ),
    );
  }
}
