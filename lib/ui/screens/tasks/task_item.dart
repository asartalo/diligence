// Diligence - A Task Management App
//
// Copyright (C) 2024 Wayne Duran <asartalo@gmail.com>
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// this program. If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/commands/commands.dart';
import '../../../models/persisted_task.dart';
import '../../../models/task.dart';
import '../../../services/diligent.dart';
import '../../../utils/clock.dart';
import '../../../utils/types.dart';
import '../../colors.dart';
import '../../components/reveal_on_hover.dart';
import '../../components/d_checkbox.dart';
import 'keys.dart' as keys;
import 'task_menu.dart';
import 'task_menu_item.dart';

part 'task_item_style.dart';

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
  final double levelScale;
  final Clock clock;

  const TaskItem({
    super.key,
    required this.task,
    required this.onUpdateTask,
    required this.onRequestTask,
    required this.onCommand,
    required this.clock,
    this.focused = false,
    this.onToggleExpandTask,
    this.level,
    this.levelScale = 30.0,
    this.childrenCount,
    this.style = TaskItemStyle.normal,
  });

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  late FocusNode focusNode;

  Task get task => widget.task;
  Clock get clock => widget.clock;

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
    return InkWell(
      key: keys.taskItem,
      onTap: () {
        widget.onRequestTask(task);
      },
      child: Container(
        padding: _getContentPadding(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: _leadSpacing(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: widget.level == null
                        ? 0
                        : widget.level! * widget.levelScale,
                  ),
                  expandTaskButton(),
                  checkbox(),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(0, 8.0, 0.0, 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.name,
                      key: keys.taskItemName,
                      style: TextStyle(
                        fontSize: _getFontSize(),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    taskDetails() ?? const SizedBox(),
                  ],
                ),
              ),
            ),
            RevealOnHover(
              child: Transform.translate(
                offset: Offset(0, _trailSpacing()),
                child: TaskMenu(
                  onClose: focusNode.requestFocus,
                  menuChildren: taskMenuItems(context),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget checkbox() {
    return RevealOnHover(
      child: Transform.translate(
        offset: Offset(_checkboxXOffset(), 0),
        child: DCheckbox(
          key: keys.taskItemCheckbox,
          value: task.done,
          size: _getCheckboxScale() * 24.0,
          // size: 24.0,
          onChanged: (bool? done) {
            widget.onUpdateTask(
              done == true
                  ? task.markDone(clock.now())
                  : task.markNotDone(clock.now()),
            );
          },
        ),
      ),
    );
  }

  List<Widget> taskMenuItems(BuildContext context) {
    final diligent = Provider.of<Diligent>(context);
    return [
      TaskMenuItem(
        key: keys.taskMenuEdit,
        icon: Icons.edit,
        label: 'Edit',
        onPressed: () {
          widget.onRequestTask(task);
        },
      ),
      TaskMenuItem(
        key: keys.taskMenuAdd,
        icon: Icons.add,
        label: 'Add Task',
        onPressed: () {
          widget.onRequestTask(diligent.newTask(parent: task));
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
        key: keys.taskMenuDelete,
        icon: Icons.delete,
        label: 'Delete',
        onPressed: () {
          widget.onCommand(DeleteTaskCommand(task: task, at: clock.now()));
        },
      ),
      focusToggle(),
    ];
  }

  Widget focusToggle() {
    return widget.focused
        ? TaskMenuItem(
            key: keys.taskMenuUnfocus,
            icon: Icons.visibility_off,
            onPressed: () {
              widget.onCommand(UnfocusTaskCommand(task: task, at: clock.now()));
            },
            label: 'Unfocus',
          )
        : TaskMenuItem(
            key: keys.taskMenuFocus,
            icon: Icons.visibility,
            onPressed: () {
              widget.onCommand(FocusTaskCommand(task: task, at: clock.now()));
            },
            label: 'Focus',
          );
  }

  Widget? taskDetails() {
    final details = task.details;

    if (details is String) {
      return Text(
        details,
        key: keys.taskItemDetails,
        style: TextStyle(
          fontSize: 14,
          color: grayText,
        ),
      );
    }

    return null;
  }

  Widget expandTaskButton() {
    if (widget.childrenCount != null) {
      if (widget.childrenCount! > 0 && widget.onToggleExpandTask != null) {
        return RevealOnHover(
          child: IconButton(
            key: keys.taskExpandButton,
            icon: Icon(task.expanded ? Icons.expand_less : Icons.expand_more),
            onPressed: () {
              widget.onToggleExpandTask!(task);
            },
          ),
        );
      }

      return const SizedBox(width: 40);
    }

    return const SizedBox(width: 0);
  }

  EdgeInsets _leadSpacing() {
    final top = switch (widget.style) {
      TaskItemStyle.focusOne => 4.0,
      TaskItemStyle.focusTwo => 8.0,
      _ => 0.0,
    };

    return EdgeInsets.only(top: top);
  }

  double _trailSpacing() {
    return switch (widget.style) {
      TaskItemStyle.focusOne => 24.0,
      TaskItemStyle.focusTwo => 12.0,
      _ => 0.0,
    };
  }

  double _checkboxXOffset() {
    return switch (widget.style) {
      TaskItemStyle.focusOne => 0.0,
      TaskItemStyle.focusTwo => 0.0,
      _ => 0.0,
    };
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

  double _getCheckboxScale() {
    switch (widget.style) {
      case TaskItemStyle.focusOne:
        return 2.0;
      case TaskItemStyle.focusTwo:
        return 1.2;
      default:
        return 1.0;
    }
  }

  EdgeInsets _getContentPadding() {
    switch (widget.style) {
      case TaskItemStyle.focusOne:
        return const EdgeInsets.fromLTRB(0, 16, 8, 16);
      case TaskItemStyle.focusTwo:
        return const EdgeInsets.fromLTRB(24, 8, 8, 8);
      default:
        return const EdgeInsets.fromLTRB(26, 2, 8, 2);
      // return const EdgeInsets.symmetric(vertical: 2, horizontal: 8);
    }
  }
}
