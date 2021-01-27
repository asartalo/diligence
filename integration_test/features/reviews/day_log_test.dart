import 'package:flutter/foundation.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import './../../app.dart' as app;
import './../../helper.dart';

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('Day Log', () {
    testWidgets('Shows log', (WidgetTester tester) async {
      await app.main();
      await navigateToReminderPage(tester);
      final dayLogField = find.byKey(const Key('fieldDayLogNotes'));
      await tester.enterText(dayLogField, 'This is a log');
      await tester.tap(find.byKey(const Key('btnSaveLog')));
      await tester.pumpAndSettle();
      final dayLogText = find.byKey(const Key('txtDayLogNotes'));
      final foo = dayLogText.evaluate().single.widget as MarkdownBody;
      expect(foo.data, contains('This is a log'));
    });
  });
}
