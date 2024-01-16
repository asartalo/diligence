import 'package:flutter_test/flutter_test.dart';

import '../helpers/dtest/dtest.dart';

Future<void> main() async {
  integrationTest('Smoke test', () {
    testApp('launching app has no errors', (dtest) async {
      await dtest.pumpAndSettle();
      expect(find.text('Diligence'), findsOneWidget);
    });
  });
}
