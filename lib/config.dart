import 'package:meta/meta.dart';

DateTime _parseDate(String dateString) {
  try {
    return DateTime.parse(dateString);
  } catch (e) {
    return null;
  }
}

@immutable
class DiligenceConfig {
  final String dbPath;
  final DateTime today;

  const DiligenceConfig({
    @required this.dbPath,
    this.today,
  });

  DiligenceConfig.fromEnv(Map<String, String> env, {bool test = false})
      : dbPath = test
            ? env['DILIGENCE_TEST_DB_PATH']
            : (env['DILIGENCE_DB_PATH'] ?? 'diligence.db'),
        today = _parseDate(env['DILIGENCE_DEV_TODAY'] ?? 'none');
}
