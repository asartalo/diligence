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

  const DiligenceConfig({
    this.today,
  });

  DiligenceConfig.fromEnv(Map<String, String> env)
      : today = _parseDate(env['DILIGENCE_DEV_TODAY'] ?? 'none');
}
