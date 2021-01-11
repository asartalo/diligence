import 'package:flutter/foundation.dart' show immutable;

@immutable
class Interval {
  final DateTime before;
  final DateTime after;
  const Interval({this.before, this.after});
}
