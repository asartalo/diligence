import 'package:diligence/diligence_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DiligenceConfig', () {
    late DiligenceConfig config;

    setUp(() {
      config = DiligenceConfig(dbPath: 'diligence.db');
    });

    test('should be able to create a config', () {
      expect(config, isA<DiligenceConfig>());
    });

    group('when dbPath is modified', () {
      setUp(() {
        config = config.copyWith(dbPath: 'new.db');
      });

      test('should return a new config with the new dbPath', () {
        expect(config.dbPath, equals('new.db'));
      });

      test('it becomes an instance of ModifiedDiligenceConfig', () {
        expect(config, isA<ModifiedDiligenceConfig>());
      });

      test('it marks dbPath field as modified', () {
        expect((config as ModifiedDiligenceConfig).modifiedFields,
            equals(['dbPath']));
      });
    });
  });
}
