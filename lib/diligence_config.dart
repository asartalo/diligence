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

import 'utils/logger.dart';

@immutable
class DiligenceConfig with EquatableMixin {
  final DateTime? today;
  final String dbPath;
  final LogLevel logLevel;
  final bool logToFile;
  final String logFilePath;

  /// Whether to show the review page.
  final bool showReviewPage;

  final Map<String, dynamic> _fields;

  DiligenceConfig({
    required this.dbPath,
    this.today,
    this.showReviewPage = false,
    this.logLevel = LogLevel.info,
    this.logToFile = false,
    this.logFilePath = '',
  }) : _fields = {
          'dbPath': dbPath,
          'showReviewPage': showReviewPage,
          'logLevel': logLevel,
          'logToFile': logToFile,
          'logFilePath': logFilePath,
        };

  dynamic get(String key) {
    if (_fields.containsKey(key)) {
      return _fields[key];
    }

    throw ArgumentError('Invalid config field key: $key');
  }

  List<String> get fields => _fields.keys.toList();

  @override
  List<Object?> get props => [
        dbPath,
        today,
        showReviewPage,
        logLevel,
        logToFile,
        logFilePath,
      ];

  DiligenceConfig copyWith({
    String? dbPath,
    bool? showDbPath,
    bool? showReviewPage,
    LogLevel? logLevel,
    bool? logToFile,
    String? logFilePath,
  }) {
    final modified = ModifiedDiligenceConfig(
      original: this,
      dbPath: dbPath ?? this.dbPath,
      showReviewPage: showReviewPage ?? this.showReviewPage,
      logLevel: logLevel ?? this.logLevel,
      logToFile: logToFile ?? this.logToFile,
      logFilePath: logFilePath ?? this.logFilePath,
    );

    if (!modified.isModified()) {
      return this;
    }

    return modified;
  }

  bool isFieldModified(String field) {
    return false;
  }

  bool isModified() {
    return false;
  }

  DiligenceConfig commit() {
    return this;
  }

  List<String> get modifiedFields => [];
}

@immutable
class ModifiedDiligenceConfig extends DiligenceConfig {
  final DiligenceConfig original;

  ModifiedDiligenceConfig({
    required this.original,
    required super.dbPath,
    super.showReviewPage,
    super.logLevel,
    super.logToFile,
    super.logFilePath,
  });

  @override
  bool isFieldModified(String field) {
    return get(field) != original.get(field);
  }

  @override
  bool isModified() {
    return modifiedFields.isNotEmpty;
  }

  @override
  List<String> get modifiedFields =>
      fields.where((field) => isFieldModified(field)).toList();

  @override
  DiligenceConfig commit() {
    return DiligenceConfig(
      dbPath: dbPath,
      showReviewPage: showReviewPage,
      logLevel: logLevel,
      logToFile: logToFile,
      logFilePath: logFilePath,
    );
  }
}
