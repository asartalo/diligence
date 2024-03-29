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

DateTime? _parseDate(String dateString) {
  try {
    return DateTime.parse(dateString);
  } catch (e) {
    return null;
  }
}

@immutable
class DiligenceConfig {
  final DateTime? today;
  final bool showDbPath;

  /// Whether to show the review page.
  final bool showReviewPage;

  const DiligenceConfig({
    this.today,
    this.showDbPath = false,
    this.showReviewPage = false,
  });

  DiligenceConfig.fromEnv(
    Map<String, String> env, {
    bool? showDbPath,
    bool? showReviewPage,
  })  : today = _parseDate(env['DILIGENCE_DEV_TODAY'] ?? 'none'),
        showDbPath = showDbPath is bool
            ? showDbPath
            : env['DILIGENCE_SHOW_DB_PATH'] == 'true',
        showReviewPage = showReviewPage is bool
            ? showReviewPage
            : env['DILIGENCE_SHOW_REVIEW_PAGE'] == 'true';
}
