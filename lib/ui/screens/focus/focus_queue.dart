import 'package:flutter/material.dart';

import '../../../models/task.dart';

class FocusQueue extends StatelessWidget {
  final List<Task> queue;
  final void Function(int oldIndex, int newIndex) onReorderQueue;
  const FocusQueue({
    super.key,
    required this.queue,
    required this.onReorderQueue,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      itemBuilder: (context, index) {
        final task = queue[index];
        return ListTile(
          key: Key(task.id.toString()),
          title: Text(task.name),
        );
      },
      itemCount: queue.length,
      onReorder: onReorderQueue,
    );
  }
}
