import 'package:flutter/foundation.dart';

import '../config.dart';

abstract class SideEffects {
  DateTime now();
}

class ProductionSideEffects extends SideEffects {
  @override
  DateTime now() => DateTime.now();
}

DateTime _toDate(DateTime toConvert, DateTime date) {
  return DateTime(
    date.year,
    date.month,
    date.day,
    toConvert.hour,
    toConvert.minute,
    toConvert.second,
    toConvert.millisecond,
    toConvert.microsecond,
  );
}

@immutable
class DevSideEffects extends SideEffects {
  final DiligenceConfig config;
  DevSideEffects(this.config) : super();

  @override
  DateTime now() {
    final realNow = DateTime.now();
    if (config.today == null) {
      return realNow;
    }
    return _toDate(realNow, config.today);
  }
}
