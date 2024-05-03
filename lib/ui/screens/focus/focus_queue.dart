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

import '../../../models/commands/commands.dart';
import '../../../models/task_list.dart';
import '../../../utils/clock.dart';
import '../../../utils/types.dart';
import '../tasks/task_item.dart';
import 'keys.dart' as keys;

class FocusQueue extends StatelessWidget {
  final TaskList queue;
  final Clock clock;
  final void Function(int oldIndex, int newIndex) onReorderQueue;
  final TaskIndexCallback onUpdateTask;
  final TaskIndexCallback onRequestTask;
  final void Function(Command command, int index) onCommand;
  final ScrollController? scrollController;

  const FocusQueue({
    super.key,
    required this.clock,
    required this.queue,
    required this.onReorderQueue,
    required this.onUpdateTask,
    required this.onRequestTask,
    required this.onCommand,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      key: keys.focusQueueList,
      buildDefaultDragHandles: false,
      shrinkWrap: true,
      scrollController: scrollController,
      itemBuilder: (context, index) {
        final task = queue[index];

        return ReorderableDelayedDragStartListener(
          key: Key('fQ-${task.id}'),
          index: index,
          child: TaskItem(
            clock: clock,
            task: task,
            focused: true,
            onUpdateTask: (task) => onUpdateTask(task, index),
            onRequestTask: (task) => onRequestTask(task, index),
            onCommand: (command) => onCommand(command, index),
            style: _getTaskItemStyle(index),
            levelScale: 8.0,
            level: _marginLeft(index),
          ),
        );
      },
      itemCount: queue.length,
      onReorder: onReorderQueue,
    );
  }

  TaskItemStyle _getTaskItemStyle(int index) {
    if (index == 0) {
      return TaskItemStyle.focusOne;
    } else if (index == 1) {
      return TaskItemStyle.focusTwo;
    } else {
      return TaskItemStyle.focusThree;
    }
  }

  int _marginLeft(int index) {
    switch (_getTaskItemStyle(index)) {
      case TaskItemStyle.focusOne:
        return 0;
      case TaskItemStyle.focusTwo:
        return 1;
      default:
        return 2;
    }
  }
}
