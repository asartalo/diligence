import 'package:diligence/di.dart';
import 'package:diligence/services/diligent.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Di', () {
    late Di di;
    setUp(() {
      di = Di();
    });

    test('it should be able to return a Diligent instance', () async {
      expect(await di.diligent, isA<Diligent>());
    });

    test('it should return the same instance each time', () async {
      final diligent1 = await di.diligent;
      final diligent2 = await di.diligent;
      expect(identical(diligent1, diligent2), isTrue);
    });
  });
}
