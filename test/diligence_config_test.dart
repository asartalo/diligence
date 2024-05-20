import 'package:diligence/diligence_config.dart';
import 'package:diligence/paths.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import 'helpers/stub_fs.dart';

void main() {
  group('DiligenceConfig', () {
    final configPath = getUserConfigPath();
    late StubFs fs;
    late DiligenceConfig config;
    const defaultConfig = DiligenceConfig(dbPath: 'diligence.db');

    setUp(() {
      fs = StubFs();
    });

    group('#fromConfigOrDefault()', () {
      test('it returns default data when there is no config file', () async {
        config = await DiligenceConfig.fromConfigOrDefault(fs);
        expect(config, defaultConfig);
      });

      group('if config file exists but empty', () {
        setUp(() async {
          fs.addFile(configPath, '');
          config = await DiligenceConfig.fromConfigOrDefault(fs);
        });

        test('it still uses default', () {
          expect(config, defaultConfig);
        });
      });

      group('if config file exists but is an invalid yaml doc', () {
        setUp(() {
          fs.addFile(configPath, '[');
        });

        test('it throws an error', () {
          expectLater(
            DiligenceConfig.fromConfigOrDefault(fs),
            throwsA(isA<InvalidYamlConfigError>()),
          );
        });
      });

      group('if config file exists and database path is correctly set', () {
        setUp(() async {
          fs.addFile(configPath, 'database:\n  path: /path/to/database');
          config = await DiligenceConfig.fromConfigOrDefault(fs);
        });

        test('it correctly parses config', () {
          expect(config, defaultConfig.copyWith(dbPath: '/path/to/database'));
        });
      });
    });

    group('#writeToConfig()', () {
      group('When there is no configuration file present', () {
        setUp(() async {
          await DiligenceConfig.writeToConfig(fs, defaultConfig);
        });

        test('it writes the config to the file', () async {
          expect(await fs.fileExists(configPath), isTrue);
        });

        test('it writes config to the file', () async {
          expect(
            loadYaml(await fs.contents(configPath)),
            {
              'database': {'path': 'diligence.db'}
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
                  configPath, '# some comments at the top\nfoo:\n  bar: baz');
              await DiligenceConfig.writeToConfig(fs, config);
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
              config = defaultConfig.copyWith(dbPath: '/path/to/database.db');
              fs.addFile(
                  configPath, 'database:\n  show: true\n\nfoo:\n  bar: baz');
              await DiligenceConfig.writeToConfig(fs, config);
            },
          );

          test('it writes config to the file', () async {
            expect(
              loadYaml(await fs.contents(configPath)),
              {
                'database': {
                  'path': '/path/to/database.db',
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
