import 'package:clock/clock.dart';

class TickingStubClock extends Clock {
  DateTime _start;
  DateTime _actualStart;

  TickingStubClock([DateTime? start])
      : _start = DateTime(2024, 4, 14),
        _actualStart = DateTime.now();

  @override
  DateTime now() {
    return _start.add(DateTime.now().difference(_actualStart));
  }

  void advance(Duration duration) {
    _start = _start.add(duration);
  }

  void setCurrentTime(DateTime time) {
    _start = time;
    _actualStart = DateTime.now();
  }
}
