import 'package:meta/meta.dart';

class DiligenceConfig {
  final String dbPath;

  DiligenceConfig({@required this.dbPath});

  DiligenceConfig.fromEnv(Map<String, String> env)
      : dbPath = env['DILIGENCE_DB_PATH'] ?? 'diligence.db';
}
