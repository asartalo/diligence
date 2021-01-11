import 'dart:io';

import 'package:diligence/config.dart';
import 'package:diligence/services/side_effects.dart';
import 'package:diligence/utils/interval.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/between_dates_matcher.dart';

const microsecond = Duration(microseconds: 1);

Interval microInterval(Function fn) {
  final before = DateTime.now();
  sleep(microsecond);
  fn();
  sleep(microsecond);
  final after = DateTime.now();
  return Interval(before: before, after: after);
}

DateTime toDate(DateTime toConvert, DateTime date) {
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

void main() {
  DevSideEffects sideEffects;

  group('DevSideEffects', () {
    group('When no "DILIGENCE_DEV_TODAY" set in config', () {
      setUp(() {
        final config = DiligenceConfig.fromEnv(const {});
        sideEffects = DevSideEffects(config);
      });

      test(
        'returns system DateTime.now()',
        () {
          DateTime now;
          final interval = microInterval(() => now = sideEffects.now());
          expect(now, isBetweenInterval(interval));
        },
      );
    });

    group('When "DILIGENCE_DEV_TODAY" is set in config', () {
      setUp(() {
        final config = DiligenceConfig.fromEnv(
            const {'DILIGENCE_DEV_TODAY': '2010-02-14'});
        sideEffects = DevSideEffects(config);
      });

      test(
        "returns that day's date with minutes and seconds set based on actual DateTime.now()",
        () {
          DateTime now;
          final interval = microInterval(() => now = sideEffects.now());

          final reference = DateTime.parse('2010-02-14');
          final before = toDate(interval.before, reference);
          final after = toDate(interval.after, reference);

          expect(now, isBetweenDates(before, after));
        },
      );
    });
  });
}
