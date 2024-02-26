import 'package:flutter/foundation.dart' show immutable;

import 'task.dart';

@immutable
class TaskNode {
  final Task task;
  final int level;
  final int childrenCount;
  final int position;

  const TaskNode({
    required this.task,
    required this.level,
    required this.childrenCount,
    required this.position,
  });

  TaskNode updateTask(Task task) => TaskNode(
        task: task,
        level: level,
        childrenCount: childrenCount,
        position: position,
      );
}
