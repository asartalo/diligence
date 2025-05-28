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
import '../../colors.dart' as colors;
import '../../components/reveal_on_hover.dart';
import '../../components/d_checkbox.dart';
import 'keys.dart' as keys;
import 'task_menu.dart';
import 'task_menu_item.dart';

part 'task_item_style.dart';

typedef TaskAncestorsCallback = Future<List<Task>> Function(Task task);

class TaskItem extends StatefulWidget {
  final Task task;
  final TaskCallback onUpdateTask;
  final TaskCallback onRequestTask;
  final TaskCommandCallback onCommand;
  final TaskCallback? onToggleExpandTask;
  final TaskAncestorsCallback? getAncestors;
  final bool focused;
  final bool showAncestry;
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
    this.getAncestors,
    this.showAncestry = false,
    this.focused = false,
    this.onToggleExpandTask,
    this.level,
    this.levelScale = 30.0,
    this.childrenCount,
    this.style = normalTaskItemStyle,
  });

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  late FocusNode focusNode;
  late List<Task> _ancestors;

  Task get task => widget.task;
  Clock get clock => widget.clock;
  TaskItemStyle get style => widget.style;
  bool get showAncestry => widget.showAncestry;
  TaskAncestorsCallback? get getAncestors => widget.getAncestors;

  @override
  void initState() {
    super.initState();
    _ancestors = [];
    if (showAncestry) {
      _getAncestors();
    }
    focusNode =
        FocusNode(debugLabel: 'TaskItem Focus Node ${task.id} ${task.name}');
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  Future<void> _getAncestors() async {
    if (getAncestors != null) {
      final ancestors = await getAncestors!(task);
      setState(() {
        _ancestors = ancestors.sublist(1); // Do not include Root task
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: keys.taskItem,
      onTap: () => widget.onRequestTask(task),
      focusNode: focusNode,
      focusColor: colors.secondaryColor,
      child: Container(
        padding: style.contentPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _breadcrumbs(),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _leader(),
                _mainContent(),
                _trailer(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Expanded _mainContent() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.name,
              key: keys.taskItemName,
              style: TextStyle(
                fontSize: style.nameFontSize,
                fontWeight: FontWeight.w300,
              ),
            ),
            _taskDetails() ?? const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget _breadcrumbs() {
    if (showAncestry) {
      final leftSpace = _expandSpacerWidth +
          style.checkboxXOffset +
          // The following value is based on containerSize calculation
          // on DCheckbox
          (_checkBoxSize * dCbDefaultContainerSize / dCbDefaultSize) -
          12.0;
      return Container(
        margin: EdgeInsets.fromLTRB(
          leftSpace,
          8.0,
          0.0,
          0.0,
        ),
        child: RevealOnHover(
          child: Wrap(
            direction: Axis.horizontal,
            alignment: WrapAlignment.start,
            children: _breadcrumbElements(),
          ),
        ),
      );
    }

    return SizedBox(width: 0.0);
  }

  List<Widget> _breadcrumbElements() {
    final List<Widget> crumbs = [];
    for (int i = 0; i < _ancestors.length; i++) {
      if (i > 0) {
        crumbs.add(const Text(' › '));
      }
      final ancestor = _ancestors[i];
      crumbs.add(
        TextButton(
          onPressed: () {},
          child: Text(ancestor.name),
        ),
      );
    }

    return crumbs;
  }

  double get _levelSpace =>
      widget.level == null ? 0 : widget.level! * widget.levelScale;

  Container _leader() {
    return Container(
      margin: EdgeInsets.only(top: style.leadSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: _levelSpace),
          _expandTaskButton(),
          _checkbox(),
        ],
      ),
    );
  }

  RevealOnHover _trailer(BuildContext context) {
    return RevealOnHover(
      child: Transform.translate(
        offset: Offset(0, style.trailSpacing),
        child: TaskMenu(
          onClose: focusNode.requestFocus,
          menuChildren: _taskMenuItems(context),
        ),
      ),
    );
  }

  double get _checkBoxSize => style.checkboxScale * 24.0;

  Widget _checkbox() {
    return RevealOnHover(
      child: Transform.translate(
        offset: Offset(style.checkboxXOffset, 0),
        child: DCheckbox(
          key: keys.taskItemCheckbox,
          value: task.done,
          size: _checkBoxSize,
          onChanged: _handleCheckToggle,
        ),
      ),
    );
  }

  void _handleCheckToggle(bool? done) {
    final now = clock.now();
    widget.onUpdateTask(
      done == true ? task.markDone(now) : task.markNotDone(now),
    );
  }

  List<Widget> _taskMenuItems(BuildContext context) {
    final diligent = Provider.of<Diligent>(context);
    return [
      TaskMenuItem(
        key: keys.taskMenuEdit,
        icon: Icons.edit,
        label: 'Edit',
        onPressed: () => widget.onRequestTask(task),
      ),
      TaskMenuItem(
        key: keys.taskMenuAdd,
        icon: Icons.add,
        label: 'Add Task',
        onPressed: () => widget.onRequestTask(diligent.newTask(parent: task)),
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
      _focusToggle(),
    ];
  }

  Widget _focusToggle() {
    return widget.focused
        ? TaskMenuItem(
            label: 'Unfocus',
            key: keys.taskMenuUnfocus,
            icon: Icons.visibility_off,
            onPressed: () => widget
                .onCommand(UnfocusTaskCommand(task: task, at: clock.now())),
          )
        : TaskMenuItem(
            label: 'Focus',
            key: keys.taskMenuFocus,
            icon: Icons.visibility,
            onPressed: () =>
                widget.onCommand(FocusTaskCommand(task: task, at: clock.now())),
          );
  }

  Widget? _taskDetails() {
    final details = task.details;

    if (details is String) {
      return Text(
        details,
        key: keys.taskItemDetails,
        style: TextStyle(
          fontSize: 14,
          color: colors.grayText,
        ),
      );
    }

    return null;
  }

  bool get hasChildrenAssigned => widget.childrenCount != null;
  bool get showExpandButton =>
      (widget.childrenCount ?? 0) > 0 && widget.onToggleExpandTask != null;

  double get _expandSpacerWidth => hasChildrenAssigned ? 40.0 : 0;

  Widget _expandTaskButton() {
    if (showExpandButton) {
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

    return SizedBox(width: _expandSpacerWidth);
  }
}
