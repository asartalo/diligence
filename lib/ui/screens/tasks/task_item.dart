import 'package:flutter/material.dart';

import '../../../models/commands/commands.dart';
import '../../../models/new_task.dart';
import '../../../models/persisted_task.dart';
import '../../../models/task.dart';
import '../../colors.dart' as colors;
import 'task_menu.dart';
import 'task_menu_item.dart';

typedef TaskCallback = void Function(Task task);
typedef TaskCommandCallback = void Function(Command command);

enum TaskItemStyle { normal, focusOne, focusTwo, focusThree }

class TaskItem extends StatefulWidget {
  final Task task;
  final TaskCallback onUpdateTask;
  final TaskCallback onRequestTask;
  final TaskCallback? onToggleExpandTask;
  final TaskCommandCallback onCommand;
  final bool focused;
  final int? level;
  final int? childrenCount;
  final TaskItemStyle style;

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
    this.style = TaskItemStyle.normal,
  });

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  late FocusNode focusNode;

  Task get task => widget.task;

  @override
  void initState() {
    super.initState();
    focusNode =
        FocusNode(debugLabel: 'TaskItem Focus Node ${task.id} ${task.name}');
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        focusNode: focusNode,
        focusColor: colors.secondaryColor,
        title: Text(
          task.name,
          style: TextStyle(
            fontSize: _getFontSize(),
          ),
        ),
        subtitle: taskDetails(),
        onTap: () async {
          widget.onRequestTask(task);
        },
        leading: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: widget.level == null ? 0 : widget.level! * 30),
                expandTaskButton(),
                checkbox(),
              ],
            ),
          ],
        ),
        trailing: TaskItemMenu(
          onClose: () {
            focusNode.requestFocus();
          },
          menuChildren: taskMenuItems(),
        ),
      ),
    );
  }

  Widget checkbox() {
    return Checkbox(
      value: task.done,
      onChanged: (bool? done) {
        widget.onUpdateTask(
          done == true ? task.markDone() : task.markNotDone(),
        );
      },
    );
  }

  List<Widget> taskMenuItems() {
    return [
      TaskMenuItem(
        icon: Icons.edit,
        label: 'Edit',
        onPressed: () {
          widget.onRequestTask(task);
        },
      ),
      TaskMenuItem(
        icon: Icons.add,
        label: 'Add Task',
        onPressed: () {
          widget.onRequestTask(NewTask(parent: task));
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
          widget.onCommand(DeleteTaskCommand(task: task));
        },
      ),
      focusToggle(),
    ];
  }

  Widget focusToggle() {
    return widget.focused
        ? TaskMenuItem(
            icon: Icons.visibility_off,
            onPressed: () {
              widget.onCommand(UnfocusTaskCommand(task: task));
            },
            label: 'Unfocus',
          )
        : TaskMenuItem(
            icon: Icons.visibility,
            onPressed: () {
              widget.onCommand(FocusTaskCommand(task: task));
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
    if (widget.childrenCount != null) {
      if (widget.childrenCount! > 0 && widget.onToggleExpandTask != null) {
        return IconButton(
          icon: Icon(task.expanded ? Icons.expand_less : Icons.expand_more),
          onPressed: () {
            widget.onToggleExpandTask!(task);
          },
        );
      }
      return const SizedBox(width: 40);
    }
    return const SizedBox(width: 0);
  }

  double _getFontSize() {
    switch (widget.style) {
      case TaskItemStyle.focusOne:
        return 48;
      case TaskItemStyle.focusTwo:
        return 32;
      default:
        return 18;
    }
  }
}
