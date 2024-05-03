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

import 'dart:math';

import 'package:flutter/material.dart';

import '../../../models/commands/commands.dart';
import '../../../models/new_task.dart';
import '../../../models/reminders/reminder_list.dart';
import '../../../models/task.dart';
import '../../../models/task_node.dart';
import '../../../models/task_pack.dart';
import '../../../services/diligent.dart';
import '../../../services/diligent/diligent_commander.dart';
import '../../../utils/clock.dart';
import '../../components/common_screen.dart';
import 'keys.dart' as keys;
import 'task_dialog.dart';
import 'task_tree.dart';

class TasksScreen extends StatefulWidget {
  final Diligent diligent;
  final DiligentCommander commander;
  final Clock clock;
  TasksScreen({super.key, required this.diligent, required this.clock})
      : commander = DiligentCommander(diligent);

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late TaskNodeList _taskNodes;
  late Task _root;

  Diligent get diligent => widget.diligent;
  Clock get clock => widget.clock;

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

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
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
        onPressed: () {
          _handleAddTaskFloatingButtonPressed();
        },
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
      child: TaskTree(
        clock: clock,
        taskNodes: _taskNodes,
        onUpdateTask: (task, index) {
          _handleUpdateTask(task, index);
        },
        onReorder: (task, index) {
          _handleReorder(task, index);
        },
        onRequestTask: (task, index) {
          _handleRequestTask(task, index);
        },
        onToggleExpandTask: (task, index) {
          _handleToggleExpandTask(task, index);
        },
        onCommand: (command, _) {
          _handleCommand(command);
        },
      ),
    );
  }

  Future<void> _handleAddTaskFloatingButtonPressed() async {
    final pack = TaskPack(
      diligent.newTask(parent: _root),
      reminders: ReminderList([]),
    );
    final command = await TaskDialog.open(context, pack: pack, clock: clock);
    if (command is Command) await _handleCommand(command);
  }

  Future<void> _handleToggleExpandTask(Task task, int _) async {
    await _expandTask(task, expanded: !task.expanded);
    await updateTaskTree();
  }

  Future<void> _handleRequestTask(Task task, int _) async {
    final pack = task is NewTask
        ? TaskPack(task, reminders: ReminderList([]))
        : await diligent.getTaskPackById(task.id);
    if (pack == null) {
      throw AssertionError(
          '_handleRequest() unexpected missing task pack for ${task.uid}');
    }
    if (!context.mounted) return;
    // ignore: use_build_context_synchronously
    final command = await TaskDialog.open(context, pack: pack, clock: clock);
    if (command is Command) {
      await _handleCommand(command);
    }
  }

  Future<void> _handleCommand(Command command) async {
    final result = await widget.commander.handle(command);
    if (result is Success) {
      if (command is NewTaskCommand) {
        await _expandParent(command.payload);
      }
      await updateTaskTree();
    }
  }

  Future<void> _handleUpdateTask(Task task, int index) async {
    setState(() {
      _taskNodes[index] = _taskNodes[index].updateTask(task);
    });
    await diligent.updateTask(task);
    await updateTaskTree();
  }

  Future<void> _expandTask(Task task, {bool expanded = true}) async {
    await diligent
        .updateTask(task.copyWith(expanded: expanded, now: clock.now()));
  }

  Future<void> _expandParent(Task task) async {
    final parentId = task.parentId;
    if (parentId is int) {
      final parent = await diligent.findTask(parentId);
      final expanded = parent?.expanded ?? false;
      if (!expanded && parent != null) {
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
