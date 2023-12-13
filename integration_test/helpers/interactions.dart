import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> tapByStringKey(WidgetTester tester, String strKey) async {
  final menuButton = find.byKey(Key(strKey));
  await tester.tap(menuButton);
  await tester.pumpAndSettle();
}
