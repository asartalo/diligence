import 'decorated_task.dart';
import 'task.dart';

class TaskNode {
  final Task task;
  final int level;
  final int childrenCount;
  final int position;

  TaskNode({
    required Task task,
    required this.level,
    required this.childrenCount,
    required this.position,
  }) : task = task is DecoratedTask ? task.task : task;

  TaskNode updateTask(Task task) => TaskNode(
        task: task,
        level: level,
        childrenCount: childrenCount,
        position: position,
      );
}
