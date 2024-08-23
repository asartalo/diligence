import 'package:diligence/config_validator.dart';
import 'package:diligence/diligence_config.dart';
import 'package:diligence/paths.dart';
import 'package:diligence/services/config_manager.dart';
import 'package:diligence/utils/logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import '../helpers/stub_fs.dart';
import '../helpers/stub_logger.dart';

class _StubValidator implements ConfigValidator {
  ConfigValidatorResult result = ConfigValidatorResult(
    true,
    'Valid config file',
  );

  @override
  Future<ConfigValidatorResult> validate(DiligenceConfig config) async {
    return result;
  }
}

void main() {
  group('ConfigManager', () {
    final configPath = getUserConfigPath();
    late ConfigManager manager;
    late StubFs fs;
    late _StubValidator validator;
    late DiligenceConfig config;
    late Logger logger;
    final defaultConfig = DiligenceConfig(dbPath: 'diligence.db');

    setUp(() {
      ConfigManager.useNonTestLogLevel();
      fs = StubFs();
      validator = _StubValidator();
      logger = StubLogger();
      manager = ConfigManager(fs, validator, logger: logger);
    });

    tearDown(() {
      ConfigManager.resetUseNonTestLogLevel();
    });

    group('#loadConfig()', () {
      test('it returns default data when there is no config file', () async {
        final result = await manager.loadConfig();
        expect(result.unwrap(), defaultConfig);
      });

      group('if config file exists but empty', () {
        setUp(() async {
          fs.addFile(configPath, '');
          config = (await manager.loadConfig()).unwrap();
        });

        test('it still uses default', () {
          expect(config, defaultConfig);
        });
      });

      group('if config file exists but is an invalid yaml doc', () {
        setUp(() {
          fs.addFile(configPath, '[');
        });

        test('it throws an error', () async {
          final result = await manager.loadConfig();
          expect(
            () => result.unwrap(),
            throwsA(isA<InvalidYamlConfigError>()),
          );
        });
      });

      group('if config file exists and database path is correctly set', () {
        setUp(() async {
          fs.addFile(configPath, 'database:\n  path: /path/to/database');
          config = (await manager.loadConfig()).unwrap();
        });

        test('it correctly parses config', () {
          expect(
            config,
            (defaultConfig.copyWith(dbPath: '/path/to/database')).commit(),
          );
        });
      });

      group('When the loaded config is invalid', () {
        setUp(() {
          validator.result = ConfigValidatorResult(
            false,
            'validation error message',
          );
          fs.addFile(configPath, 'database:\n  path: /path/to/database');
        });

        test('it throws an error', () async {
          final result = await manager.loadConfig();
          expect(
            () => result.unwrap(),
            throwsA(isA<ConfigValidationException>()),
          );
        });
      });
    });

    group('#saveConfig()', () {
      group('When the config is invalid', () {
        setUp(() {
          validator.result = ConfigValidatorResult(
            false,
            'validation error message',
          );
          config = defaultConfig.copyWith(dbPath: '/path/to/database');
        });

        test('it throws an error', () async {
          final result = await manager.saveConfig(config);
          expect(
            () => result.unwrap(),
            throwsA(isA<ConfigValidationException>()),
          );
        });
      });

      group('When there is no configuration file present', () {
        setUp(() async {
          await manager.saveConfig(defaultConfig.copyWith(
            dbPath: 'mydiligence.db',
          ));
        });

        test('it writes the config to the file', () async {
          expect(await fs.fileExists(configPath), isTrue);
        });

        test('it writes config to the file', () async {
          expect(
            loadYaml(await fs.contents(configPath)),
            {
              'database': {'path': 'mydiligence.db'}
            },
          );
        });
      });

      group(
        'When there is a configuration file present with missing field group',
        () {
          setUp(
            () async {
              config = defaultConfig.copyWith(dbPath: '/path/to/database.db');
              fs.addFile(
                configPath,
                '# some comments at the top\nfoo:\n  bar: baz',
              );
              await manager.saveConfig(config);
            },
          );

          test('it writes config to the file', () async {
            expect(
              loadYaml(await fs.contents(configPath)),
              {
                'database': {'path': '/path/to/database.db'},
                'foo': {'bar': 'baz'},
              },
            );
          });

          test('it preserves comments', () async {
            final contents = await fs.contents(configPath);
            expect(
              contents,
              contains('# some comments at the top'),
            );
          });
        },
      );

      group(
        'When there is a configuration file present with missing leaf field',
        () {
          setUp(
            () async {
              config = defaultConfig.copyWith(dbPath: '/a/path/to/database.db');
              fs.addFile(
                  configPath, 'database:\n  show: true\n\nfoo:\n  bar: baz');
              await manager.saveConfig(config);
            },
          );

          test('it writes config to the file', () async {
            expect(
              loadYaml(await fs.contents(configPath)),
              {
                'database': {
                  'path': '/a/path/to/database.db',
                  'show': true,
                },
                'foo': {'bar': 'baz'},
              },
            );
          });
        },
      );
    });
  });
}
