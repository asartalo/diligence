import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/clock.dart';

typedef WithClockBuilder = Widget Function(Clock clock, BuildContext context);

class WithClock extends StatelessWidget {
  final WithClockBuilder builder;
  const WithClock({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final clock = Provider.of<Clock>(context);
    return builder(clock, context);
  }
}
