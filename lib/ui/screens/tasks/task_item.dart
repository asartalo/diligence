import 'package:flutter/material.dart';

import '../../../models/new_task.dart';
import '../../../models/task.dart';

typedef TaskCallback = void Function(Task task);

class TaskItem extends StatelessWidget {
  final Task task;
  final TaskCallback onUpdateTask;
  final TaskCallback onRequestTask;
  final TaskCallback? onToggleExpandTask;
  final int? level;
  final int? childrenCount;

  const TaskItem({
    super.key,
    required this.task,
    required this.onUpdateTask,
    required this.onRequestTask,
    this.onToggleExpandTask,
    this.level,
    this.childrenCount,
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
                SizedBox(width: level == null ? 0 : level! * 30),
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
    if (childrenCount != null) {
      if (childrenCount! > 0 && onToggleExpandTask != null) {
        return IconButton(
          icon: Icon(task.expanded ? Icons.expand_less : Icons.expand_more),
          onPressed: () {
            onToggleExpandTask!(task);
          },
        );
      }
      return const SizedBox(width: 40);
    }
    return const SizedBox(width: 0);
  }
}
