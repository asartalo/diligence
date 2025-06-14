import 'package:diligence/di/app_state_scope.dart';
import 'package:diligence/di/root_scope.dart';
import 'package:diligence/diligence_config.dart';
import 'package:diligence/services/diligent.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Di', () {
    late AppStateScope di;
    setUp(() {
      final rootScope = RootScope(isTest: true);
      di = AppStateScope(
        parent: rootScope,
        config: DiligenceConfig(dbPath: 'test.db'),
      );
    });

    test('it should be able to return a Diligent instance', () {
      expect(di.diligent, isA<Diligent>());
    });

    test('it should return the same instance each time', () {
      final diligent1 = di.diligent;
      final diligent2 = di.diligent;
      expect(identical(diligent1, diligent2), isTrue);
    });
  });
}
