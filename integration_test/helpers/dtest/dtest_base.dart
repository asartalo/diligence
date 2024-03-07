import 'package:diligence/diligence_container.dart';
import 'package:diligence/services/diligent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class DtestBase {
  final WidgetTester tester;
  final DiligenceContainer container;

  Diligent get diligent => container.diligent;

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
}
