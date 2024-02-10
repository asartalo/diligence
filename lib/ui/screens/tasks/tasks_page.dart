import 'dart:math';

import 'package:flutter/material.dart';

import '../../../models/commands/commands.dart';
import '../../../models/commands/focus_task_command.dart';
import '../../../models/decorated_task.dart';
import '../../../models/new_task.dart';
import '../../../models/task.dart';
import '../../../models/task_node.dart';
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
  late TaskNodeList _taskNodes;
  late Task _root;

  Diligent get diligent => widget.diligent;

  @override
  void initState() {
    super.initState();
    _taskNodes = [];
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

  void updateTasks(TaskNodeList taskNodes, {Task? root}) {
    setState(() {
      _taskNodes = taskNodes;
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
        taskNodes: _taskNodes,
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

  Future<void> _handleToggleExpandTask(Task task, int _) async {
    await _expandTask(task, expanded: !task.expanded);
    await updateTaskTree();
  }

  Future<void> _handleRequestTask(Task task, int _) async {
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
    } else if (command is FocusTaskCommand) {
      await diligent.focus(command.payload);
      await updateTaskTree();
    }
  }

  Future<void> _handleUpdateTask(Task task, int index) async {
    setState(() {
      _taskNodes[index] = _taskNodes[index].updateTask(task);
    });
    await diligent.updateTask(trueTask(task));
    await updateTaskTree();
  }

  Task trueTask(Task task) {
    if (task is DecoratedTask) {
      return task.task;
    }
    return task;
  }

  Future<void> _expandTask(Task task, {bool expanded = true}) async {
    await diligent.updateTask(trueTask(task.copyWith(expanded: expanded)));
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
    late TaskNode referenceNode;
    if (newIndex > _taskNodes.length - 1) {
      referenceNode = _taskNodes[newIndex - 1];
      position = referenceNode.position + 1;
      parentId = referenceNode.task.parentId;
    } else {
      referenceNode = _taskNodes[newIndex];
      position = referenceNode.position;
      parentId = referenceNode.task.parentId;
    }
    final taskNode = _taskNodes.removeAt(oldIndex);
    setState(() {
      // Let's move the element inline so we don't see a flicker
      _taskNodes.insert(
        max(0, oldIndex > newIndex ? newIndex : newIndex - 1),
        taskNode,
      );
    });

    if (parentId != null) {
      final parent = await diligent.findTask(parentId);
      await diligent.moveTask(
        taskNode.task,
        position,
        parent: parent,
      );
      updateTaskTree();
    }
  }
}
