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

  const DiligenceConfig({
    this.today,
    this.showDbPath = false,
  });

  DiligenceConfig.fromEnv(Map<String, String> env)
      : today = _parseDate(env['DILIGENCE_DEV_TODAY'] ?? 'none'),
        showDbPath = env['DILIGENCE_SHOW_DB_PATH'] == 'true';
}
