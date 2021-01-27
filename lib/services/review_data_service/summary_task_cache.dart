import 'package:sqflite/sqflite.dart' show Database;

class SummaryTaskCache {
  final Map<int, String> _nameCache = {};
  final Database db;

  SummaryTaskCache(this.db);

  Future<String> get(int id) async {
    return '';
  }

  Future<List<String>> getAll(List<int> ids) async {
    final settingsResult = await db.rawQuery('''
      SELECT max_idle_minutes
      FROM "settings"
      LIMIT 1;
    ''');
  }
}
