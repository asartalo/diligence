import 'dart:async';

import 'package:diligence/utils/stub_clock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TickingStubClock', () {
    late StubClock clock;
    final startNow = DateTime(2024, 4, 12, 16);

    setUp(() {
      clock = StubClock(startNow);
    });

    test('it starts at the given time', () {
      expect(
        clock.now().millisecondsSinceEpoch,
        startNow.millisecondsSinceEpoch,
      );
    });

    test('it advances time', () {
      const duration = Duration(days: 1);
      clock.advance(duration);
      expect(
        clock.now().millisecondsSinceEpoch,
        startNow.add(duration).millisecondsSinceEpoch,
      );
    });

    group('Single Timers', () {
      int timerCalled = 0;
      late Timer timer;

      setUp(() {
        timerCalled = 0;
        timer = clock.timer(const Duration(seconds: 1), () {
          timerCalled++;
        });
      });

      test('it is active by default', () {
        expect(timer.isActive, isTrue);
      });

      test('its callback is not called immediately', () {
        expect(timerCalled, 0);
      });

      test('its tick is 0', () {
        expect(timer.tick, 0);
      });

      group('When the clock duration passes', () {
        setUp(() {
          clock.advance(const Duration(seconds: 1));
        });

        test('the timer callback is run', () {
          expect(timerCalled, 1);
        });

        test('the timer is no longer active', () {
          expect(timer.isActive, isFalse);
        });

        test('the timer tick is incremented', () {
          expect(timer.tick, 1);
        });
      });

      group('When time passes after the timer is run', () {
        setUp(() {
          clock.advance(const Duration(seconds: 1));
          clock.advance(const Duration(seconds: 1));
        });

        test('the timer callback is not run again', () {
          expect(timerCalled, 1);
        });

        test('the timer is still inactive', () {
          expect(timer.isActive, isFalse);
        });

        test('the timer tick is still 1', () {
          expect(timer.tick, 1);
        });
      });

      group('When timer is cancelled', () {
        setUp(() {
          timer.cancel();
        });

        test('the timer is no longer active', () {
          expect(timer.isActive, isFalse);
        });

        test('the timer callback is never run', () {
          clock.advance(const Duration(seconds: 1));
          expect(timerCalled, 0);
        });

        test('the tick is never incremented', () {
          clock.advance(const Duration(seconds: 1));
          expect(timer.tick, 0);
        });
      });
    });

    group('Periodic Timers', () {
      int timerCalled = 0;
      late Timer timer;

      setUp(() {
        timerCalled = 0;
        timer = clock.periodic(const Duration(seconds: 1), (timer) {
          timerCalled++;
        });
      });

      test('it is active by default', () {
        expect(timer.isActive, isTrue);
      });

      test('its callback is not called immediately', () {
        expect(timerCalled, 0);
      });

      test('its tick is 0', () {
        expect(timer.tick, 0);
      });

      group('When the clock duration passes one time', () {
        setUp(() {
          clock.advance(const Duration(seconds: 1));
        });

        test('the timer callback is run', () {
          expect(timerCalled, 1);
        });

        test('the timer is still active', () {
          expect(timer.isActive, isTrue);
        });

        test('the timer tick is incremented', () {
          expect(timer.tick, 1);
        });
      });

      group('When the clock duration passes multiple times', () {
        setUp(() {
          clock.advance(const Duration(seconds: 3));
        });

        test('the timer callback is called accordingly', () {
          expect(timerCalled, 3);
        });

        test('the timer is still active', () {
          expect(timer.isActive, isTrue);
        });

        test('the timer tick is incremented', () {
          expect(timer.tick, 3);
        });
      });

      group('When the multi-duration passes and timer is cancelled', () {
        setUp(() {
          clock.advance(const Duration(seconds: 3));
          timer.cancel();
          clock.advance(const Duration(seconds: 3));
        });

        test('the timer stops after cancel', () {
          expect(timer.tick, 3);
        });

        test('the timer is no longer active', () {
          expect(timer.isActive, isFalse);
        });
      });
    });

    group('Timer Runs Interleaving', () {
      List<String> runs = [];
      List<String> run1 = [];
      List<String> run2 = [];

      setUp(() {
        runs = [];
        clock.timer(seconds(1), () {
          runs.add('O1');
        });
        final p2 = clock.periodic(seconds(2), (tm) {
          runs.add('P2 ${tm.tick}');
        });
        clock.periodic(seconds(3), (tm) {
          runs.add('P3 ${tm.tick}');
        });
        clock.advance(seconds(5));
        run1 = runs.toList();
        runs = [];
        clock.timer(seconds(1), () {
          runs.add('O2');
        });
        clock.advance(seconds(3));
        p2.cancel();
        clock.advance(seconds(2));
        run2 = runs.toList();
      });

      test('it interleaves runs correctly', () {
        expect(run1, ['O1', 'P2 0', 'P3 0', 'P2 1']);
        expect(run2, ['P2 2', 'P3 1', 'O2', 'P2 3', 'P3 2']);
      });
    });

    group('Time Travel', () {
      List<String> runs = [];

      setUp(() {
        runs = [];
        clock.timer(seconds(1), () {
          runs.add('O1');
        });
        clock.periodic(seconds(2), (tm) {
          runs.add('P2 ${tm.tick}');
        });
        clock.periodic(seconds(3), (tm) {
          runs.add('P3 ${tm.tick}');
        });
        clock.timer(seconds(1), () {
          runs.add('O2');
        });
        clock.timeTravel(clock.now().add(seconds(10)));
      });

      test('it only runs latest timers', () {
        expect(runs, ['O1', 'O2', 'P3 2', 'P2 4']);
      });
    });
  });
}

Duration seconds(int amount) => Duration(seconds: amount);
