import 'package:flutter/material.dart';

import '../../../models/commands/commands.dart';
import '../../../services/diligent.dart';
import '../../../utils/types.dart';
import 'keys.dart' as keys;
import 'task_item.dart';

class TaskTree extends StatelessWidget {
  final TaskNodeList taskNodes;
  final TaskIndexCallback onUpdateTask;
  final TaskIndexCallback onRequestTask;
  final TaskIndexCallback onToggleExpandTask;
  final void Function(Command command, int index) onCommand;
  final void Function(int oldIndex, int newIndex) onReorder;

  const TaskTree({
    super.key,
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
