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
