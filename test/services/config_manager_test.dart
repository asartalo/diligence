import 'package:diligence/config_validator.dart';
import 'package:diligence/diligence_config.dart';
import 'package:diligence/services/config_file_paths.dart';
import 'package:diligence/services/config_manager.dart';
import 'package:diligence/services/file_write_viability_checker.dart';
import 'package:diligence/services/logger/logger.dart';
import 'package:diligence/utils/fs.dart';
import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yaml/yaml.dart';

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

class MockConfigFilePaths extends Mock implements ConfigFilePaths {}

void main() {
  group('ConfigManager', () {
    final configPath = '/home/john/diligence.yaml';
    late ConfigManager manager;
    late MemoryFileSystem fileSystem;
    late Fs fs;
    late _StubValidator validator;
    late DiligenceConfig config;
    late Logger logger;
    final defaultConfig = DiligenceConfig(dbPath: 'diligence.db');
    final configFilePaths = MockConfigFilePaths();

    setUp(() async {
      ConfigManager.useNonTestLogLevel();
      fileSystem = MemoryFileSystem();
      fs = Fs(fileSystem);
      validator = _StubValidator();
      logger = StubLogger();
      await fileSystem.directory('/home/john').create(recursive: true);
      manager = ConfigManager(
        fs,
        validator,
        configFilePaths: configFilePaths,
        logger: logger,
      );
      final List<FileWriteViabilityChecker> paths = [
        FileWriteViabilityChecker(
          fs: fs,
          unOwnedParentPath: '/home/john/',
          subPath: 'diligence.yaml',
        ),
      ];
      when(() => configFilePaths.getProbableConfigFilePaths())
          .thenAnswer((_) => paths);
    });

    Future<void> setConfigContent(String content) async {
      await fileSystem.directory('/home/john').create(recursive: true);
      await fileSystem.file('/home/john/diligence.yaml').writeAsString(content);
    }

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
          await setConfigContent('');
          config = (await manager.loadConfig()).unwrap();
        });

        test('it still uses default', () {
          expect(config, defaultConfig);
        });
      });

      group('if config file exists but is an invalid yaml doc', () {
        setUp(() async {
          await setConfigContent('[');
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
          await setConfigContent('database:\n  path: /path/to/database');
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
        setUp(() async {
          validator.result = ConfigValidatorResult(
            false,
            'validation error message',
          );
          await setConfigContent('database:\n  path: /path/to/database');
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
              await setConfigContent(
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
              await setConfigContent(
                'database:\n  show: true\n\nfoo:\n  bar: baz',
              );
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
