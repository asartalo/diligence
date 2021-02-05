import 'package:meta/meta.dart';

DateTime? _parseDate(String dateString) {
  try {
    return DateTime.parse(dateString);
  } catch (e) {
    return null;
  }
}

String _getDbPath(Map<String, String> env, bool test) {
  final result =
      test ? env['DILIGENCE_TEST_DB_PATH'] : env['DILIGENCE_DB_PATH'];
  if (result is String) {
    return result;
  }
  return 'diligence.db';
}

@immutable
class DiligenceConfig {
  final String dbPath;
  final DateTime? today;

  const DiligenceConfig({
    required this.dbPath,
    this.today,
  });

  DiligenceConfig.fromEnv(Map<String, String> env, {bool test = false})
      : dbPath = _getDbPath(env, test),
        today = _parseDate(env['DILIGENCE_DEV_TODAY'] ?? 'none');
}
