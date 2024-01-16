import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class DtestBase {
  final WidgetTester tester;

  DtestBase(this.tester);

  Future<void> tapByStringKey(String strKey) => tapByKey(Key(strKey));

  Future<void> tapByKey(Key key) async {
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
}
