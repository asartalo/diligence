// Diligence - A Task Management App
//
// Copyright (C) 2024 Wayne Duran <asartalo@gmail.com>
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// this program. If not, see <https://www.gnu.org/licenses/>.

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'paths.dart';
import 'utils/fs.dart';

@immutable
class DiligenceConfig with EquatableMixin {
  final DateTime? today;
  final bool showDbPath;
  final String dbPath;

  /// Whether to show the review page.
  final bool showReviewPage;

  const DiligenceConfig({
    required this.dbPath,
    this.today,
    this.showDbPath = false,
    this.showReviewPage = false,
  });

  @override
  List<Object?> get props => [dbPath, today, showDbPath, showReviewPage];

  // Loads configuration from yaml config file.
  //
  // The decision to use YAML is simply for easier manipulation with yaml_edit
  // making it possible to edit the config files while preserving formatting and
  // comments. If there is a library that does this for TOML then we might
  // implement it.
  static Future<DiligenceConfig> fromConfigOrDefault(
    Fs fs, {
    bool? showDbPath,
    bool? showReviewPage,
    String? dbPath,
  }) async {
    final path = getUserConfigPath();
    String realDbPath = dbPath ?? 'diligence.db';
    bool realShowDb = showDbPath ?? false;
    bool realShowReview = showReviewPage ?? false;

    if (await fs.fileExists(path)) {
      final doc = _parseYaml(await fs.contents(path));

      if (doc != null) {
        realDbPath = _pathValueOrDefault('database.path', realDbPath, doc);
        realShowDb = _pathValueOrDefault('database.show', realShowDb, doc);
        realShowReview =
            _pathValueOrDefault('show_review_page', realShowReview, doc);
      }
    }

    return DiligenceConfig(
      dbPath: realDbPath,
      showDbPath: realShowDb,
      showReviewPage: realShowReview,
    );
  }

  static dynamic _parseYaml(String yamlContents) {
    try {
      return loadYaml(yamlContents);
    } catch (err) {
      throw InvalidYamlConfigError(getUserConfigPath());
    }
  }

  static Future<void> writeToConfig(Fs fs, DiligenceConfig config) async {
    final path = getUserConfigPath();
    final configFileExists = await fs.fileExists(path);
    String contents = '';

    if (!configFileExists) {
      contents = 'database:\n  path: ${config.dbPath}';
    } else {
      final doc = _parseYaml(await fs.contents(path));

      YamlEditor editor = YamlEditor(await fs.contents(path));
      if (doc['database'] == null) {
        editor.update(['database'], {'path': config.dbPath});
      } else {
        editor.update(['database', 'path'], config.dbPath);
      }

      contents = editor.toString();
    }

    fs.write(path, contents);
  }

  DiligenceConfig copyWith({
    String? dbPath,
    bool? showDbPath,
    bool? showReviewPage,
  }) {
    return DiligenceConfig(
      dbPath: dbPath ?? this.dbPath,
      showDbPath: showDbPath ?? this.showDbPath,
      showReviewPage: showReviewPage ?? this.showReviewPage,
    );
  }
}

class InvalidYamlConfigError extends StateError {
  InvalidYamlConfigError(String configFilePath)
      : super(
          'The config file "$configFilePath" does not appear to be a valid config file',
        );
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
