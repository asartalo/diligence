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

import 'dart:async';

import 'package:flutter/material.dart';

import '../../utils/clock.dart';

typedef ClockCallback = Widget Function(DateTime time);

class ClockWrap extends StatefulWidget {
  final ClockCallback builder;
  final Clock clock;
  const ClockWrap({super.key, required this.builder, required this.clock});

  @override
  State<ClockWrap> createState() => _ClockWrapState();
}

DateTime _nextExactMinute(DateTime time) {
  return DateTime(
    time.year,
    time.month,
    time.day,
    time.hour,
    time.minute + 1,
  );
}

Duration _untilNextExactMinute(DateTime time, Clock clock) {
  final roundUpMinute = _nextExactMinute(time);
  return roundUpMinute.difference(clock.now());
}

const oneMinute = Duration(minutes: 1);

class _ClockWrapState extends State<ClockWrap> {
  Timer? timer;
  late DateTime time;

  Clock get clock => widget.clock;

  @override
  void initState() {
    super.initState();
    time = clock.now();
    clock.timer(_untilNextExactMinute(time, clock), () {
      updateTime();
      timer = clock.periodic(oneMinute, (_) => updateTime());
    });
  }

  @override
  void dispose() {
    if (timer is Timer) {
      timer!.cancel();
    }
    super.dispose();
  }

  void updateTime() {
    if (mounted) {
      setState(() {
        time = clock.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(time);
  }
}
