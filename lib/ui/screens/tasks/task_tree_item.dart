import 'package:flutter/material.dart';

import '../../../models/new_task.dart';
import '../../../models/task.dart';

class TaskTreeItem extends StatelessWidget {
  final Task task;
  final void Function(Task task) onUpdateTask;
  final void Function(Task task) onRequestTask;
  final void Function(Task task) onToggleExpandTask;
  final int level;
  final int childrenCount;

  const TaskTreeItem({
    super.key,
    required this.task,
    required this.onUpdateTask,
    required this.onRequestTask,
    required this.onToggleExpandTask,
    required this.level,
    this.childrenCount = 0,
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
          onRequestTask(task);
        },
        leading: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: level * 30),
                expandTaskButton(),
                Checkbox(
                  value: task.done,
                  onChanged: (bool? done) {
                    onUpdateTask(
                      done == true ? task.markDone() : task.markNotDone(),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            onRequestTask(NewTask(parent: task));
          },
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

  Widget expandTaskButton() {
    if (childrenCount > 0) {
      return IconButton(
        icon: Icon(task.expanded ? Icons.expand_less : Icons.expand_more),
        onPressed: () {
          onToggleExpandTask(task);
        },
      );
    }
    return const SizedBox(width: 40);
  }
}
