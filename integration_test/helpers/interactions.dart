import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> tapByStringKey(WidgetTester tester, String strKey) =>
    tapByKey(tester, Key(strKey));

Future<void> tapByKey(WidgetTester tester, Key key) async {
  final menuButton = find.byKey(key);
  await tester.tap(menuButton);
  await tester.pumpAndSettle();
}
