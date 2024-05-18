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

import 'package:meta/meta.dart';
import 'package:toml/toml.dart';

import 'paths.dart';
import 'utils/fs.dart';

@immutable
class DiligenceConfig {
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

  static Future<DiligenceConfig> fromConfigOrDefault(
    Fs fs, {
    bool? showDbPath,
    bool? showReviewPage,
    String? dbPath,
  }) async {
    final path = getUserConfigPath();
    String actualDbPath = dbPath ?? 'diligence.db';
    bool actualShowDbPath = showDbPath ?? false;
    bool actualShowReviewPage = showReviewPage ?? false;

    if (await fs.exists(path)) {
      final doc = TomlDocument.parse(await fs.contents(path)).toMap();
      final dbPathInConfig = doc['database']?['path'] as String?;
      if (dbPathInConfig is String) {
        actualDbPath = dbPathInConfig;
      }

      final showDbPathInConfig = doc['database']?['show'] as bool?;
      if (showDbPathInConfig is bool) {
        actualShowDbPath = showDbPathInConfig;
      }

      final showReviewPageInConfig = doc['dev']?['show_review_page'] as bool?;
      if (showReviewPageInConfig is bool) {
        actualShowReviewPage = showReviewPageInConfig;
      }
    }

    return DiligenceConfig(
      dbPath: actualDbPath,
      showDbPath: actualShowDbPath,
      showReviewPage: actualShowReviewPage,
    );
  }
}
