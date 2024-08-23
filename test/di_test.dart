import 'package:diligence/di.dart';
import 'package:diligence/diligence_config.dart';
import 'package:diligence/services/diligent.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Di', () {
    late Di di;
    setUp(() {
      di = Di(
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
