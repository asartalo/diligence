import 'package:flutter/material.dart';

import '../../../models/task.dart';
import '../../../services/diligent.dart';
import 'keys.dart' as keys;
import 'task_tree_item.dart';

class TaskTree extends StatelessWidget {
  final TaskNodeList taskNodes;
  final void Function(Task task, int index) onUpdateTask;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(Task task, int index) onRequestTask;
  final void Function(Task task, int index) onToggleExpandTask;

  const TaskTree({
    super.key,
    required this.taskNodes,
    required this.onUpdateTask,
    required this.onReorder,
    required this.onRequestTask,
    required this.onToggleExpandTask,
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
          child: TaskTreeItem(
            taskNode: taskNode,
            onUpdateTask: (task) => onUpdateTask(task, index),
            onRequestTask: (task) => onRequestTask(task, index),
            onToggleExpandTask: (task) => onToggleExpandTask(task, index),
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
