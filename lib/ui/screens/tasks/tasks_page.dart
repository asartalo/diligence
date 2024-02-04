import 'dart:math';

import 'package:flutter/material.dart';

import '../../../models/commands/commands.dart';
import '../../../models/leveled_task.dart';
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
  late Task _root;

  Diligent get diligent => widget.diligent;

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
    final root = await diligent.findTask(1);
    // TODO: Find a way to guarantee root task is always present.
    if (root == null) {
      throw Exception('Root task not found');
    }
    final tasks = await diligent.expandedDescendantsTree(root);
    updateTasks(tasks, root: root);
  }

  void updateTasks(List<Task> tasks, {Task? root}) {
    setState(() {
      _tasks = tasks;
      if (root != null) {
        _root = root;
      }
    });
  }

  Future<void> updateTaskTree({Task? root}) async {
    updateTasks(
      await diligent.expandedDescendantsTree(root ?? _root),
      root: root,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonScreen(
      title: 'Tasks',
      floatingActionButton: FloatingActionButton(
        key: keys.addTaskFloatingButton,
        onPressed: _handleAddTaskFloatingButtonPressed,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
      child: TaskTree(
        tasks: _tasks,
        onUpdateTask: _handleUpdateTask,
        onReorder: _handleReorder,
        onRequestTask: _handleRequestTask,
        onToggleExpandTask: _handleToggleExpandTask,
      ),
    );
  }

  Future<void> _handleAddTaskFloatingButtonPressed() async {
    final command = await TaskDialog.open(context, NewTask(parent: _root));
    if (command is NewTaskCommand) {
      final newTask = command.payload;
      await diligent.addTask(newTask);
      await updateTaskTree();
    }
  }

  Future<void> _handleToggleExpandTask(Task task) async {
    await _expandTask(task, expanded: !task.expanded);
    await updateTaskTree();
  }

  Future<void> _handleRequestTask(Task task) async {
    final command = await TaskDialog.open(context, task);
    if (command is NewTaskCommand) {
      final addedTask = await diligent.addTask(command.payload);
      if (addedTask is Task) {
        await _expandParent(addedTask);
      }
      await updateTaskTree();
    } else if (command is UpdateTaskCommand) {
      await diligent.updateTask(command.payload);
      await updateTaskTree();
    } else if (command is DeleteTaskCommand) {
      await diligent.deleteTask(command.payload);
      await updateTaskTree();
    }
  }

  Future<void> _handleUpdateTask(Task task, int index) async {
    setState(() {
      _tasks[index] = task;
    });
    await diligent.updateTask(task);
    setState(() {
      _tasks[index] = task;
    });
  }

  Future<void> _expandTask(Task task, {bool expanded = true}) async {
    await diligent.updateTask(task.copyWith(expanded: expanded));
  }

  Future<void> _expandParent(Task task) async {
    final parentId = task.parentId;
    if (parentId is int) {
      final parent = await diligent.findTask(parentId);
      final expanded = parent!.expanded;
      if (!expanded) {
        await _expandTask(parent);
      }
    }
  }

  Future<void> _handleReorder(int oldIndex, int newIndex) async {
    int position = newIndex;
    late int? parentId;
    late LeveledTask referenceTask;
    if (newIndex > _tasks.length - 1) {
      referenceTask = _tasks[newIndex - 1] as LeveledTask;
      position = referenceTask.position + 1;
      parentId = referenceTask.parentId;
    } else {
      referenceTask = _tasks[newIndex] as LeveledTask;
      parentId = referenceTask.parentId;
      position = referenceTask.position;
    }
    final task = _tasks.removeAt(oldIndex);
    setState(() {
      // Let's move the element inline so we don't see a flicker
      _tasks.insert(
        max(0, oldIndex > newIndex ? newIndex : newIndex - 1),
        task,
      );
    });

    if (parentId != null) {
      final parent = await diligent.findTask(parentId);
      if (task is LeveledTask) {
        await diligent.moveTask(
          task,
          position,
          parent: parent,
        );
        updateTaskTree();
      }
    }
  }
}
