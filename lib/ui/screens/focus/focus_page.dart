import 'dart:math';

import 'package:flutter/widgets.dart';

import '../../../models/task.dart';
import '../../../services/diligent.dart';
import '../../components/common_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    return CommonScreen(
      title: 'Focus',
      child: FocusQueue(
        queue: _queue,
        onReorderQueue: _handleReorderQueue,
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
    // await diligent.reprioritizeInFocusQueue(_queue);
    updateQueue(_queue);
  }
}
