import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> tapByStringKey(WidgetTester tester, String strKey) =>
    tapByKey(tester, Key(strKey));

Future<void> tapByKey(WidgetTester tester, Key key) async {
  final element = find.byKey(key);
  return tapElement(tester, element);
}

Future<void> tapElement(WidgetTester tester, Finder element) async {
  await tester.tap(element);
  await tester.pumpAndSettle();
}
