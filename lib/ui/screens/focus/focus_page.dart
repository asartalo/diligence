import 'dart:math';

import 'package:flutter/widgets.dart';

import '../../../models/commands/delete_task_command.dart';
import '../../../models/commands/focus_task_command.dart';
import '../../../models/commands/update_task_command.dart';
import '../../../models/task.dart';
import '../../../services/diligent.dart';
import '../../components/common_screen.dart';
import '../tasks/task_dialog.dart';
import 'focus_queue.dart';

class FocusPage extends StatefulWidget {
  final Diligent diligent;
  const FocusPage({super.key, required this.diligent});

  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
  late List<Task> _queue;

  Diligent get diligent => widget.diligent;

  @override
  void initState() {
    super.initState();
    _queue = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    populateQueue();
  }

  Future<void> populateQueue() async {
    final queue = await diligent.focusQueue();
    updateQueue(queue);
  }

  void updateQueue(List<Task> queue) {
    setState(() {
      _queue = queue;
    });
  }

  Future<void> updateTasks() async {
    final queue = await diligent.focusQueue();
    updateQueue(queue);
  }

  @override
  Widget build(BuildContext context) {
    return CommonScreen(
      title: 'Focus',
      child: FocusQueue(
        queue: _queue,
        onReorderQueue: _handleReorderQueue,
        onRequestTask: _handleRequestTask,
        onUpdateTask: _handleUpdateTask,
      ),
    );
  }

  Future<void> _handleReorderQueue(int oldIndex, int newIndex) async {
    final task = _queue.removeAt(oldIndex);
    setState(() {
      _queue.insert(
        max(0, oldIndex > newIndex ? newIndex : newIndex - 1),
        task,
      );
    });
    await diligent.reprioritizeInFocusQueue(task, newIndex);
    await updateTasks();
  }

  Future<void> _handleRequestTask(Task task, int index) async {
    final command = await TaskDialog.open(context, task);
    if (command is UpdateTaskCommand) {
      await diligent.updateTask(command.payload);
      await updateTasks();
    } else if (command is DeleteTaskCommand) {
      await diligent.deleteTask(command.payload);
      await updateTasks();
    } else if (command is FocusTaskCommand) {
      await diligent.focus(command.payload);
      await updateTasks();
    }
  }

  Future<void> _handleUpdateTask(Task task, int index) async {
    setState(() {
      _queue[index] = task;
    });
    await diligent.updateTask(task);
    await updateTasks();
  }
}
