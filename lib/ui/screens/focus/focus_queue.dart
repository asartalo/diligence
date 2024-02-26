import 'package:flutter/material.dart';

import '../../../models/commands/commands.dart';
import '../../../models/task.dart';
import '../tasks/task_item.dart';

class FocusQueue extends StatelessWidget {
  final List<Task> queue;
  final void Function(int oldIndex, int newIndex) onReorderQueue;
  final void Function(Task task, int index) onUpdateTask;
  final void Function(Task task, int index) onRequestTask;
  final void Function(Command command, int index) onCommand;

  const FocusQueue({
    super.key,
    required this.queue,
    required this.onReorderQueue,
    required this.onUpdateTask,
    required this.onRequestTask,
    required this.onCommand,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      itemBuilder: (context, index) {
        final task = queue[index];
        return TaskItem(
          key: Key('fQ-${task.id}'),
          task: task,
          focused: true,
          onUpdateTask: (task) => onUpdateTask(task, index),
          onRequestTask: (task) => onRequestTask(task, index),
          onCommand: (command) => onCommand(command, index),
        );
      },
      itemCount: queue.length,
      onReorder: onReorderQueue,
    );
  }
}
