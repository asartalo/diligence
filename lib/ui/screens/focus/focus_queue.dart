import 'package:flutter/material.dart';

import '../../../models/commands/commands.dart';
import '../../../services/diligent.dart';
import '../../../utils/types.dart';
import '../tasks/task_item.dart';
import 'keys.dart' as keys;

class FocusQueue extends StatelessWidget {
  final TaskList queue;
  final void Function(int oldIndex, int newIndex) onReorderQueue;
  final TaskIndexCallback onUpdateTask;
  final TaskIndexCallback onRequestTask;
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
      key: keys.focusQueueList,
      buildDefaultDragHandles: false,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final task = queue[index];
        return ReorderableDelayedDragStartListener(
          key: Key('fQ-${task.id}'),
          index: index,
          child: TaskItem(
            task: task,
            focused: true,
            onUpdateTask: (task) => onUpdateTask(task, index),
            onRequestTask: (task) => onRequestTask(task, index),
            onCommand: (command) => onCommand(command, index),
            style: _getTaskItemStyle(index),
            levelScale: 8.0,
            level: _marginLeft(index),
          ),
        );
      },
      itemCount: queue.length,
      onReorder: onReorderQueue,
    );
  }

  TaskItemStyle _getTaskItemStyle(int index) {
    if (index == 0) {
      return TaskItemStyle.focusOne;
    } else if (index == 1) {
      return TaskItemStyle.focusTwo;
    } else {
      return TaskItemStyle.focusThree;
    }
  }

  int _marginLeft(int index) {
    switch (_getTaskItemStyle(index)) {
      case TaskItemStyle.focusOne:
        return 0;
      case TaskItemStyle.focusTwo:
        return 1;
      default:
        return 2;
    }
  }
}
