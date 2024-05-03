import 'dart:async';

import 'package:collection/collection.dart';

import 'clock.dart';

class ObjWithTime<T> {
  final T obj;
  final DateTime time;
  final int? tick;

  ObjWithTime(this.obj, this.time, [this.tick]);

  @override
  String toString() {
    return 'ObjWithTime{time: $time, obj: $obj, tick: $tick}';
  }
}

typedef TimerRuntimes = List<ObjWithTime<RunnableTimer>>;

abstract class RunnableTimer implements Timer {
  bool _isActive = true;
  int _tick = 0;

  @override
  int get tick => _tick;

  @override
  bool get isActive => _isActive;

  DateTime get started;

  void setTick(int tick) {
    _tick = tick;
  }

  @override
  void cancel() {
    inactivate();
  }

  void inactivate() {
    _isActive = false;
  }

  void incrementTick() {
    _tick++;
  }

  void run(DateTime now);

  TimerRuntimes runTimesUntil(DateTime now, bool lastOnesOnly);
}

class StubbedSingleTimer extends RunnableTimer {
  final Duration duration;
  final void Function() callback;

  @override
  final DateTime started;

  StubbedSingleTimer(this.duration, this.callback, this.started);

  bool shouldRun(DateTime now) {
    final runAt = started.add(duration);
    return _isActive && !runAt.isAfter(now); // runAt >= now
  }

  @override
  void run(DateTime now) {
    if (shouldRun(now)) {
      callback();
      incrementTick();
      inactivate();
    }
  }

  @override
  TimerRuntimes runTimesUntil(DateTime now, bool lastOnesOnly) {
    if (shouldRun(now)) {
      return [ObjWithTime(this, started.add(duration))];
    }
    return [];
  }
}

class StubbedPeriodicTimer extends RunnableTimer {
  final Duration duration;
  DateTime _lastRunRef = DateTime(0);
  final void Function(Timer timer) callback;

  @override
  final DateTime started;

  StubbedPeriodicTimer(this.duration, this.callback, this.started)
      : _lastRunRef = started;

  @override
  void run(DateTime now) {
    if (isActive) {
      callback(this);
      _lastRunRef = now;
      incrementTick();
    }
  }

  @override
  TimerRuntimes runTimesUntil(DateTime now, bool lastOnesOnly) {
    final elapsedFromLastRun = now.difference(_lastRunRef);
    if (!isActive || elapsedFromLastRun < duration) {
      return [];
    }

    if (lastOnesOnly) {
      final total = elapsedFromLastRun.inMilliseconds;
      final d = duration.inMilliseconds;
      final mod = total % d;
      final tick = total ~/ d;
      final lastWhen = _lastRunRef.add(
        Duration(milliseconds: total - mod),
      );
      return [ObjWithTime(this, lastWhen, tick)];
    }

    TimerRuntimes runTimes = [];
    var reference = duration;
    final maxDuration = now.difference(_lastRunRef);

    while (reference <= maxDuration) {
      runTimes.add(ObjWithTime(this, _lastRunRef.add(reference)));
      reference += duration;
    }

    return runTimes;
  }
}

final defaultStartTime = DateTime(2024, 4, 14);

class StubClock implements Clock {
  DateTime _current;

  final List<RunnableTimer> _timers = [];

  StubClock([DateTime? start]) : _current = start ?? defaultStartTime;

  @override
  DateTime now() {
    return _current;
  }

  void advance(Duration duration) {
    setCurrentTime(_current.add(duration));
    _runTimers();
  }

  void setCurrentTime(DateTime time) {
    _current = time;
  }

  // Like advance but only runs the last periodic timers ticks
  void timeTravel(DateTime time) {
    setCurrentTime(time);
    _runTimers(true);
  }

  void _runTimers([bool lastOnesOnly = false]) {
    final List<TimerRuntimes> runtimesList = [];
    for (final timer in _timers) {
      if (timer.isActive) {
        runtimesList.add(timer.runTimesUntil(_current, lastOnesOnly));
      }
    }

    final runtimes = runtimesList.flattened.sortedBy((pair) => pair.time);
    for (final pair in runtimes) {
      if (pair.tick is int) {
        pair.obj.setTick(pair.tick! - 1);
      }
      pair.obj.run(pair.time);
    }
    _cleanupTimers();
  }

  void _cleanupTimers() {
    _timers.removeWhere((timer) => !timer.isActive);
  }

  @override
  Timer timer(Duration duration, void Function() callback) {
    final t = StubbedSingleTimer(duration, callback, _current);
    _timers.add(t);
    return t;
  }

  @override
  Timer periodic(Duration duration, void Function(Timer timer) callback) {
    final t = StubbedPeriodicTimer(duration, callback, _current);
    _timers.add(t);
    return t;
  }
}
