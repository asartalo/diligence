import 'package:flutter/material.dart';

import '../../../models/commands/commands.dart';
import '../../../models/new_task.dart';
import '../../../models/persisted_task.dart';
import '../../../models/task.dart';
import 'task_menu.dart';
import 'task_menu_item.dart';

typedef TaskCallback = void Function(Task task);
typedef TaskCommandCallback = void Function(Command command);

class TaskItem extends StatelessWidget {
  final Task task;
  final TaskCallback onUpdateTask;
  final TaskCallback onRequestTask;
  final TaskCallback? onToggleExpandTask;
  final TaskCommandCallback onCommand;
  final bool focused;
  final int? level;
  final int? childrenCount;

  const TaskItem({
    super.key,
    required this.task,
    required this.onUpdateTask,
    required this.onRequestTask,
    required this.onCommand,
    this.focused = false,
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
        trailing: TaskItemMenu(
          menuChildren: taskMenuItems(),
        ),
      ),
    );
  }

  List<Widget> taskMenuItems() {
    return [
      TaskMenuItem(
        icon: Icons.edit,
        label: 'Edit',
        onPressed: () {
          onRequestTask(task);
        },
      ),
      TaskMenuItem(
        icon: Icons.add,
        label: 'Add Task',
        onPressed: () {
          onRequestTask(NewTask(parent: task));
        },
      ),
      ...task is PersistedTask
          ? _taskMenuItemsPersisted(task as PersistedTask)
          : [],
    ];
  }

  List<Widget> _taskMenuItemsPersisted(PersistedTask task) {
    return [
      TaskMenuItem(
        icon: Icons.delete,
        label: 'Delete',
        onPressed: () {
          onCommand(DeleteTaskCommand(payload: task));
        },
      ),
      focusToggle(),
    ];
  }

  Widget focusToggle() {
    return focused
        ? TaskMenuItem(
            icon: Icons.visibility_off,
            onPressed: () {
              onCommand(UnfocusTaskCommand(payload: task));
            },
            label: 'Unfocus',
          )
        : TaskMenuItem(
            icon: Icons.visibility,
            onPressed: () {
              onCommand(FocusTaskCommand(payload: task));
            },
            label: 'Focus',
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
