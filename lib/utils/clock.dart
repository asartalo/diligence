import 'dart:async';
import 'package:clock/clock.dart' as official;

abstract class Clock {
  DateTime now();

  factory Clock() => const _SystemClock();

  Timer timer(Duration duration, void Function() callback);

  Timer periodic(Duration duration, void Function(Timer timer) callback);
}

class _SystemClock implements Clock {
  const _SystemClock();

  @override
  DateTime now() => official.clock.now();

  @override
  Timer timer(Duration duration, void Function() callback) {
    return Timer(duration, callback);
  }

  @override
  Timer periodic(Duration duration, void Function(Timer timer) callback) {
    return Timer.periodic(duration, callback);
  }
}
