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

  /// Whether to show the review page.
  final bool showReviewPage;

  const DiligenceConfig({
    required this.dbPath,
    this.today,
    this.showReviewPage = false,
    this.logLevel = LogLevel.info,
  });

  @override
  List<Object?> get props => [
        dbPath,
        today,
        showReviewPage,
        logLevel,
      ];

  DiligenceConfig copyWith({
    String? dbPath,
    bool? showDbPath,
    bool? showReviewPage,
    LogLevel? logLevel,
  }) {
    return DiligenceConfig(
      dbPath: dbPath ?? this.dbPath,
      showReviewPage: showReviewPage ?? this.showReviewPage,
      logLevel: logLevel ?? this.logLevel,
    );
  }
}
