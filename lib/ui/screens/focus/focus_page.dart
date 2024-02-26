import 'dart:math';

import 'package:flutter/widgets.dart';

import '../../../models/commands/commands.dart';
import '../../../models/task.dart';
import '../../../services/diligent.dart';
import '../../../services/diligent/commander.dart';
import '../../components/common_screen.dart';
import '../tasks/task_dialog.dart';
import 'focus_queue.dart';

class FocusPage extends StatefulWidget {
  final Diligent diligent;
  final DiligentCommander commander;
  FocusPage({super.key, required this.diligent})
      : commander = DiligentCommander(diligent);

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
    updateTasks();
  }

  void updateQueue(List<Task> queue) {
    setState(() {
      _queue = queue;
    });
  }

  Future<void> updateTasks() async {
    final queue = await diligent.focusQueue(limit: 5);
    updateQueue(queue);
  }

  @override
  Widget build(BuildContext context) {
    return CommonScreen(
      title: 'Focus',
      child: Container(
        margin: const EdgeInsets.fromLTRB(64.0, 48.0, 64.0, 0.0),
        child: FocusQueue(
          queue: _queue,
          onReorderQueue: _handleReorderQueue,
          onRequestTask: _handleRequestTask,
          onUpdateTask: _handleUpdateTask,
          onCommand: _handleCommand,
        ),
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
    if (command is Command) {
      await _handleCommand(command, index);
    }
  }

  Future<void> _handleUpdateTask(Task task, int index) async {
    setState(() {
      _queue[index] = task;
    });
    await diligent.updateTask(task);
    await updateTasks();
  }

  Future<void> _handleCommand(Command command, int _) async {
    final result = await widget.commander.handle(command);
    if (result is Success) {
      await updateTasks();
    }
  }
}
