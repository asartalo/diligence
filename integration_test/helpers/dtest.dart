import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import './../app.dart' as app;

void integrationTest(String description, void Function() fn) {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group(description, () {
    tearDown(() async {
      await Future<void>.delayed(const Duration(seconds: 1));
    });

    setUp(() async {
      final file = File('test.db');
      if (await file.exists()) {
        await file.delete();
      }
    });

    fn();
  });
}

void testApp(
  String description,
  WidgetTesterCallback callback, {
  dynamic tags,
  bool? skip,
}) {
  testWidgets(description, (widgetTester) async {
    await app.main();
    return callback(widgetTester);
  }, tags: tags, skip: skip);
}
