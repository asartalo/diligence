import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../../app.dart' as app;
import 'dtest_base.dart';
import 'navigation.dart';

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

class Dtest extends DtestBase with DtestNavigation {
  Dtest(super.tester);
}

typedef TestAppCallback = Future<void> Function(Dtest dtest);

void testApp(
  String description,
  TestAppCallback callback, {
  dynamic tags,
  bool? skip,
}) {
  testWidgets(description, (widgetTester) async {
    await app.main();
    return callback(Dtest(widgetTester));
  }, tags: tags, skip: skip);
}