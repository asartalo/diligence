import 'package:flutter_test/flutter_test.dart';

import '../../helpers/dtest/dtest.dart';

Future<void> main() async {
  integrationTest('Day Log', () {
    testApp('Shows log', (dtest) async {
      await dtest.navigateToReminderPage();
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
