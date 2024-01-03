import 'package:flutter_test/flutter_test.dart';

import '../../helpers/dtest.dart';
import '../../helpers/navigation.dart';

Future<void> main() async {
  integrationTest('Day Log', () {
    testApp('Shows log', (WidgetTester tester) async {
      await navigateToReminderPage(tester);
      // final dayLogField = find.byKey(const Key('fieldDayLogNotes'));
      // await tester.enterText(dayLogField, 'This is a log');
      // await tester.tap(find.byKey(const Key('btnSaveLog')));
      // await tester.pumpAndSettle();
      // final dayLogText = find.byKey(const Key('txtDayLogNotes'));
      // final foo = dayLogText.evaluate().single.widget as MarkdownBody;
      // expect(foo.data, contains('This is a log'));
    });
  });
}
