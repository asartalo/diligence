import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import '../config_validator.dart';
import '../diligence_config.dart';
import '../paths.dart';
import '../result.dart';
import '../utils/fs.dart';

class ConfigManager {
  final Fs fs;
  final ConfigValidator validator;
  final bool test;

  ConfigManager(this.fs, this.validator, {this.test = false});

  // Loads configuration from yaml config file.
  //
  // When the constructor is passed with `this.test = true`, the config file
  // is never loaded and the default values are used. This makes it easier for
  // testing especially in integration tests.
  //
  // Config files are loaded from the user's home directory. If the file does
  // not exist, the default values are used.
  //
  // The decision to use YAML is simply for easier manipulation with yaml_edit
  // making it possible to edit the config files while preserving formatting and
  // comments. If there is a library that does this for TOML then we might
  // implement it.
  Future<ConfigManagerResult> loadConfig({
    bool? showDbPath,
    bool? showReviewPage,
    String? dbPath,
  }) async {
    bool realShowDb = showDbPath ?? false;
    bool realShowReview = showReviewPage ?? false;
    String? realDbPath = dbPath ?? 'diligence.db';
    final path = getUserConfigPath();

    if (!test && await fs.fileExists(path)) {
      try {
        final doc = _parseYaml(await fs.contents(path));

        if (doc != null) {
          realDbPath = _pathValueOrDefault('database.path', realDbPath, doc);
          realShowDb = _pathValueOrDefault('database.show', realShowDb, doc);
          realShowReview =
              _pathValueOrDefault('show_review_page', realShowReview, doc);
        }
      } on InvalidYamlConfigError catch (err) {
        return Failure(err);
      }
    }

    final config = DiligenceConfig(
      dbPath: realDbPath,
      showDbPath: realShowDb,
      showReviewPage: realShowReview,
    );

    final validationResult = await validator.validate(config);
    if (!validationResult.success) {
      return Failure(ConfigValidationException(validationResult.message));
    }

    return Success(config);
  }

  static dynamic _parseYaml(String yamlContents) {
    try {
      return loadYaml(yamlContents);
    } catch (err) {
      throw InvalidYamlConfigError(getUserConfigPath());
    }
  }

  // Saves the configuration to a local config file
  //
  // See `loadConfig()` for more information.
  Future<ConfigManagerResult> saveConfig(DiligenceConfig config) async {
    final validationResult = await validator.validate(config);
    if (!validationResult.success) {
      return Failure(ConfigValidationException(validationResult.message));
    }

    final path = getUserConfigPath();
    final configFileExists = await fs.fileExists(path);
    String contents = '';

    if (!configFileExists) {
      contents = 'database:\n  path: ${config.dbPath}';
    } else {
      try {
        final doc = _parseYaml(await fs.contents(path));

        YamlEditor editor = YamlEditor(await fs.contents(path));
        if (doc['database'] == null) {
          editor.update(['database'], {'path': config.dbPath});
        } else {
          editor.update(['database', 'path'], config.dbPath);
        }

        contents = editor.toString();
      } on InvalidYamlConfigError catch (err) {
        return Failure(err);
      }
    }

    fs.write(path, contents);
    return Success(config);
  }
}

T? _valueFromPath<T>(String path, dynamic doc) {
  if (doc == null) return null;
  if (path == '') return doc as T;

  final pathParts = path.split('.');
  final last = pathParts.length - 1;
  dynamic current = doc as Map;

  for (var i = 0; i < pathParts.length; i++) {
    final part = pathParts[i];
    current = current[part];
    if (current == null) {
      return null;
    }
    if (i == last) {
      return current as T;
    }
  }
  return null;
}

T _pathValueOrDefault<T>(String path, T defaultValue, dynamic doc) {
  final value = _valueFromPath<T>(path, doc);
  return value ?? defaultValue;
}

class ConfigManagerException implements Exception {
  final String message;

  ConfigManagerException(this.message);
}

class ConfigValidationException extends ConfigManagerException {
  ConfigValidationException(super.message);
}

class InvalidYamlConfigError extends ConfigManagerException {
  InvalidYamlConfigError(String configFilePath)
      : super(
          'The config file "$configFilePath" does not appear to be a valid config file',
        );
}

typedef ConfigManagerResult = Result<DiligenceConfig, ConfigManagerException>;
