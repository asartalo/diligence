import 'package:flutter/material.dart';

import '../../../models/task.dart';
import 'keys.dart' as keys;

class TaskTree extends StatelessWidget {
  final List<Task> tasks;
  final void Function(Task task, int index) onUpdateTask;
  final void Function(int oldIndex, int newIndex) onReorder;
  const TaskTree({
    super.key,
    required this.tasks,
    required this.onUpdateTask,
    required this.onReorder,
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
          child: CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(task.name),
            onChanged: (bool? done) {
              onUpdateTask(task.copyWith(done: done ?? false), index);
            },
            value: task.done,
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
