import 'package:sqflite/sqflite.dart' show Database;

String? _findNamesFromResult(List<Map<String, Object?>> result, int id) {
  final itemIndex = result.indexWhere((element) {
    final theId = element['id'];
    return theId is int && theId == id;
  });
  if (itemIndex != -1) {
    final item = result[itemIndex];
    // delete it from result so next indexWhere will be quicker
    result.removeAt(itemIndex);
    final theName = item['name'];
    if (theName is String) {
      return theName;
    }
  }
  return null;
}

class SummaryTaskCache {
  final Map<int, String> _nameCache = {};
  final Database db;

  SummaryTaskCache(this.db);

  Future<String> get(int id) async {
    return (await getAll([id])).first;
  }

  Future<List<Map<String, Object?>>> _queryNames(List<int> ids) async {
    final joinedList = ids.join(',');
    return (await db.rawQuery('''
        SELECT name, id
        FROM "tasks"
        WHERE id IN ($joinedList);
      ''')).sublist(0);
  }

  Future<List<String>> getAll(List<int> ids) async {
    final List<String> names = [];
    final idsToQuery = ids.where((id) => !_nameCache.containsKey(id)).toList();
    List<Map<String, Object?>> result = [];
    if (idsToQuery.isNotEmpty) {
      result = await _queryNames(idsToQuery);
    }

    for (final id in ids) {
      final name = _nameCache[id] ?? _findNamesFromResult(result, id) ?? '';
      names.add(name);
      _nameCache[id] = name;
    }
    return names;
  }
}
