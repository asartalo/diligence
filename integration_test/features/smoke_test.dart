import 'package:flutter_test/flutter_test.dart';

import '../helpers/dtest.dart';

Future<void> main() async {
  integrationTest('Smoke test', () {
    testApp('launching app has no errors', (WidgetTester tester) async {
      await tester.pumpAndSettle();
      expect(find.text('Diligence'), findsOneWidget);
    });
  });
}
