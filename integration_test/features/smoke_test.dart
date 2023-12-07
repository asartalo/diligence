import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import './../app.dart' as app;

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('Smoke test', () {
    testWidgets('launching app has no errors', (WidgetTester tester) async {
      await app.main();
      await tester.pumpAndSettle();
      expect(find.text('Diligence'), findsOneWidget);
    });
  });
}
