import 'dart:convert';

import 'package:diligence/utils/cast.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';

final loadAssetString = rootBundle.loadString;

Future<Database> setupDatabase(String path) async {
  final initialSchema = await loadAssetString('data/schema.sql');
  final manifestContent = await loadAssetString('AssetManifest.json');
  final Map<String, dynamic> manifestMap = castOrDefault<Map<String, dynamic>>(
    json.decode(manifestContent),
    {},
  );
  final migrations = manifestMap.keys
      .where((String key) =>
          key.startsWith('data/migrations/') && key.endsWith('.sql'))
      .toList();
  return openDatabase(
    path,
    version: migrations.length + 1,
    onCreate: (Database db, int version) async {
      await db.execute(initialSchema);
    },
    onUpgrade: (Database db, int oldVersion, int newVersion) async {
      for (int i = oldVersion - 1; i < newVersion - 1; i++) {
        final sql = await loadAssetString(migrations[i]);
        await db.execute(sql);
      }
    },
  );
}
