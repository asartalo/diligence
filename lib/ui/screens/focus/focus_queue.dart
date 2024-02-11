import 'package:flutter/material.dart';

import '../../../models/task.dart';
import '../tasks/task_item.dart';

class FocusQueue extends StatelessWidget {
  final List<Task> queue;
  final void Function(int oldIndex, int newIndex) onReorderQueue;
  final void Function(Task task, int index) onUpdateTask;
  final void Function(Task task, int index) onRequestTask;

  const FocusQueue({
    super.key,
    required this.queue,
    required this.onReorderQueue,
    required this.onUpdateTask,
    required this.onRequestTask,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      itemBuilder: (context, index) {
        final task = queue[index];
        return TaskItem(
          key: Key('fQ-${task.id}'),
          task: task,
          onUpdateTask: (task) => onUpdateTask(task, index),
          onRequestTask: (task) => onRequestTask(task, index),
        );
      },
      itemCount: queue.length,
      onReorder: onReorderQueue,
    );
  }
}
