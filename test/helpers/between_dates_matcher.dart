import 'package:diligence/utils/interval.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_test/flutter_test.dart';

@immutable
class BetweenDatesMatcher extends Matcher {
  final DateTime before;
  final DateTime after;
  const BetweenDatesMatcher(this.before, this.after);

  @override
  Description describe(Description description) {
    return description.add('DateTime is between $before and $after');
  }

  @override
  bool matches(covariant DateTime item, Map<dynamic, dynamic> matchState) {
    return item.isBefore(after) && item.isAfter(before);
  }

  @override
  Description describeMismatch(covariant DateTime item,
      Description mismatchDescription, Map matchState, bool verbose) {
    final described =
        super.describeMismatch(item, mismatchDescription, matchState, verbose);
    if (!item.isBefore(after)) {
      described.add('$item is not before $after');
    }

    if (!item.isAfter(before)) {
      described.add('$item is not after $before');
    }
    return described;
  }
}

BetweenDatesMatcher isBetweenDates(DateTime before, DateTime after) {
  return BetweenDatesMatcher(before, after);
}

BetweenDatesMatcher isBetweenInterval(Interval interval) {
  return BetweenDatesMatcher(interval.before, interval.after);
}
