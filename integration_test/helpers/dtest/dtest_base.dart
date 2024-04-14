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

import 'package:diligence/diligence_container.dart';
import 'package:diligence/services/diligent.dart';
import 'package:diligence/utils/ticking_stub_clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class DtestBase {
  final WidgetTester tester;
  final DiligenceContainer container;

  Diligent get diligent => container.diligent;

  TickingStubClock get clock => container.diligent.clock as TickingStubClock;

  DtestBase(this.tester, {required this.container});

  Future<void> tapByStringKey(String strKey) => tapByKey(Key(strKey));

  Future<void> tapByKey(Key key) {
    final element = find.byKey(key);

    return tapElement(element);
  }

  Future<void> tapElement(Finder element) async {
    await tester.tap(element);
    await pumpAndSettle();
  }

  Future<int> pumpAndSettle() => tester.pumpAndSettle();

  Future<void> enterText(Finder element, String text) =>
      tester.enterText(element, text);

  Future<void> enterTextByKey(Key key, String text) =>
      enterText(find.byKey(key), text);

  void setClockCurrentTime(DateTime now) {
    clock.setCurrentTime(now);
  }

  void advanceClock(Duration duration) {
    clock.advance(duration);
  }
}
