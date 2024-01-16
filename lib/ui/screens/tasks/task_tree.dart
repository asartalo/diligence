import 'package:flutter/material.dart';

import '../../../models/task.dart';
import 'keys.dart' as keys;
import 'task_tree_item.dart';

class TaskTree extends StatelessWidget {
  final List<Task> tasks;
  final void Function(Task task, int index) onUpdateTask;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(Task task) onRequestEditTask;

  const TaskTree({
    super.key,
    required this.tasks,
    required this.onUpdateTask,
    required this.onReorder,
    required this.onRequestEditTask,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      key: keys.mainTaskList,
      buildDefaultDragHandles: false,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return ReorderableDelayedDragStartListener(
          key: Key(task.id.toString()),
          index: index,
          child: TaskTreeItem(
            task: task,
            onUpdateTask: (task) => onUpdateTask(task, index),
            onRequestEditTask: onRequestEditTask,
          ),
        );
      },
      itemCount: tasks.length,
      onReorder: (oldIndex, newIndex) async {
        onReorder(oldIndex, oldIndex > newIndex ? newIndex : newIndex - 1);
      },
    );
  }
}
