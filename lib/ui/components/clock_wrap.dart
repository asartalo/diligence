import 'dart:async';

import 'package:flutter/material.dart';

typedef ClockCallback = Widget Function(DateTime time);

class ClockWrap extends StatefulWidget {
  final ClockCallback builder;
  const ClockWrap({super.key, required this.builder});

  @override
  State<ClockWrap> createState() => _ClockWrapState();
}

class _ClockWrapState extends State<ClockWrap> {
  late Timer timer;
  late DateTime time;

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
    return widget.builder(time);
  }
}
