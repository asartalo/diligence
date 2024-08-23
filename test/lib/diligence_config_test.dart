import 'package:diligence/diligence_config.dart';
import 'package:diligence/utils/logger.dart';
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

    group('Accessing values using string keys', () {
      setUp(() {
        config = DiligenceConfig(
          dbPath: 'diligence.db',
          showReviewPage: true,
          logLevel: LogLevel.debug,
          logToFile: true,
          logFilePath: '/path/to/log',
        );
      });

      final testData = [
        _KeyVP('dbPath', () => config.dbPath),
        _KeyVP('showReviewPage', () => config.showReviewPage),
        _KeyVP('logLevel', () => config.logLevel),
        _KeyVP('logToFile', () => config.logToFile),
        _KeyVP('logFilePath', () => config.logFilePath),
      ];

      for (final data in testData) {
        test('should return the value of "${data.key}"', () {
          expect(config.get(data.key), data.originalValue());
        });
      }

      test('should throw ArgumentError when key is not found', () {
        expect(() => config.get('notFound'), throwsA(isA<ArgumentError>()));
      });

      test('it can retrive all keys', () {
        expect(
          Set<String>.from(config.fields),
          equals(
            Set<String>.from(testData.map((e) => e.key).toList()),
          ),
        );
      });
    });
  });
}

typedef ReturnsT<T> = T Function();

class _KeyVP<T> {
  final String key;
  final T Function() originalValue;

  _KeyVP(this.key, this.originalValue);
}
