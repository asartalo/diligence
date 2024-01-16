import 'package:flutter/material.dart';

import '../../../models/task.dart';

class TaskTreeItem extends StatelessWidget {
  final Task task;
  final void Function(Task task) onUpdateTask;
  final void Function(Task task) onRequestEditTask;

  const TaskTreeItem({
    super.key,
    required this.task,
    required this.onUpdateTask,
    required this.onRequestEditTask,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        title: Text(task.name),
        subtitle: taskDetails(),
        // hoverColor: Colors.green,
        onTap: () async {
          onRequestEditTask(task);
        },
        leading: Column(
          children: [
            SizedBox(height: task.details is String ? 0.0 : 8.0),
            Checkbox(
              value: task.done,
              onChanged: (bool? done) {
                onUpdateTask(task.copyWith(done: done ?? false));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget? taskDetails() {
    final details = task.details;
    if (details is String) {
      return Text(details);
    }
    return null;
  }
}
