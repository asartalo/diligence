import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dtest.dart';

@immutable
abstract class TestScreen {
  final Dtest dtest;

  WidgetTester get tester => dtest.tester;

  Finder get taskList;

  const TestScreen(this.dtest);
}
