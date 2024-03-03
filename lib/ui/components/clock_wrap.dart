import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef ClockCallback = Widget Function(DateTime time);

class ClockWrap extends StatefulWidget {
  final ClockCallback clockCallback;
  const ClockWrap({super.key, required this.clockCallback});

  @override
  State<ClockWrap> createState() => _ClockWrapState();
}

class _ClockWrapState extends State<ClockWrap> {
  late Timer timer;
  late DateTime time;
  final dateFormat = DateFormat('EEEE, MMMM d, y H:mm a');

  @override
  void initState() {
    super.initState();
    time = DateTime.now();
    timer = Timer.periodic(const Duration(minutes: 1), (Timer t) {
      if (mounted) {
        setState(() {
          time = DateTime.now();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.clockCallback(time);
  }
}
