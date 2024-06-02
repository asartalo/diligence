import 'package:diligence/config_validator.dart';
import 'package:diligence/diligence_config.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/stub_fs.dart';

void main() {
  group('ConfigValidator', () {
    late StubFs fs;
    late ConfigValidator validator;

    setUp(() {
      fs = StubFs();
      validator = ConfigValidator(fs);
    });

    group('#validate()', () {
      test(
        'succeeds when config path directory exists',
        () async {
          fs.addFile('/existing/path.db', '');
          const config = DiligenceConfig(dbPath: '/existing/path.db');
          expect(
            await validator.validate(config),
            ConfigValidatorResult(true, 'Valid config file'),
          );
        },
      );

      test('fails when config path directory does not exist', () async {
        const config = DiligenceConfig(dbPath: '/non/existent/path.db');
        expect(
          await validator.validate(config),
          ConfigValidatorResult(
            false,
            'Database path directory "/non/existent" does not exist',
          ),
        );
      });
    });
  });
}
