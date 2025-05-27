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

@immutable
abstract class TaskStyler {
  TaskItemStyle style(int index);
}

@immutable
class TaskStylerWide extends TaskStyler {
  TaskStylerWide();

  @override
  TaskItemStyle style(int index) {
    if (index == 0) {
      return focus1stTaskItemStyle;
    } else if (index == 1) {
      return focus2ndTaskItemStyle;
    } else {
      return focusOthersTaskItemStyle;
    }
  }
}

@immutable
class TaskStylerNarrow extends TaskStyler {
  TaskStylerNarrow();

  @override
  TaskItemStyle style(int index) {
    if (index == 0) {
      return focus1stNarrowTaskItemStyle;
    } else {
      return focusOthersNarrowTaskItemStyle;
    }
  }
}

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
    return LayoutBuilder(builder: (context, constraints) {
      final styler =
          constraints.maxWidth < 600 ? TaskStylerNarrow() : TaskStylerWide();
      return ReorderableListView.builder(
        key: keys.focusQueueList,
        buildDefaultDragHandles: false,
        shrinkWrap: true,
        scrollController: scrollController,
        itemBuilder: (context, index) {
          final task = queue[index];
          final style = styler.style(index);

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
              style: style,
              levelScale: 8.0,
              level: style.marginLeft,
            ),
          );
        },
        itemCount: queue.length,
        onReorder: onReorderQueue,
      );
    });
  }
}
