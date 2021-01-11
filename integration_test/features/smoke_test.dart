import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import './../app.dart' as app;

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('smoke test', () {
    testWidgets('failing test example', (WidgetTester tester) async {
      await app.main();
      await tester.pumpAndSettle();

      expect(find.text('Review'), findsOneWidget);
    });
  });
}
