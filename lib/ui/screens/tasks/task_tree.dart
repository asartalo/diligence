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
import '../../../services/diligent.dart';
import '../../../utils/clock.dart';
import '../../../utils/types.dart';
import 'keys.dart' as keys;
import 'task_item.dart';

class TaskTree extends StatelessWidget {
  final TaskNodeList taskNodes;
  final TaskIndexCallback onUpdateTask;
  final TaskIndexCallback onRequestTask;
  final TaskIndexCallback onToggleExpandTask;
  final Clock clock;
  final void Function(Command command, int index) onCommand;
  final void Function(int oldIndex, int newIndex) onReorder;

  const TaskTree({
    super.key,
    required this.clock,
    required this.taskNodes,
    required this.onUpdateTask,
    required this.onReorder,
    required this.onRequestTask,
    required this.onToggleExpandTask,
    required this.onCommand,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      key: keys.mainTaskList,
      buildDefaultDragHandles: false,
      itemBuilder: (context, index) {
        final taskNode = taskNodes[index];
        final task = taskNode.task;

        return ReorderableDelayedDragStartListener(
          key: Key(task.id.toString()),
          index: index,
          child: TaskItem(
            task: task,
            clock: clock,
            onUpdateTask: (task) => onUpdateTask(task, index),
            onRequestTask: (task) => onRequestTask(task, index),
            onToggleExpandTask: (task) => onToggleExpandTask(task, index),
            onCommand: (command) => onCommand(command, index),
            level: taskNode.level,
            childrenCount: taskNode.childrenCount,
          ),
        );
      },
      itemCount: taskNodes.length,
      onReorder: onReorder,
    );
  }
}
