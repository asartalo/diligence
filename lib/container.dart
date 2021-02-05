import 'dart:convert';

import 'package:diligence/services/review_data/review_data_bloc.dart';
import 'package:diligence/services/review_data_service.dart';
import 'package:diligence/services/side_effects.dart';
import 'package:diligence/utils/cast.dart';
import 'package:diligence/utils/sqflite_prepare.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dot_env;
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:sqflite/sqflite.dart';

// import 'package:flutter/foundation.dart' show kReleaseMode;

import 'config.dart';

final loadAssetString = rootBundle.loadString;

class DiligenceContainer {
  final DiligenceConfig config;
  final Database database;

  DiligenceContainer({
    required this.config,
    required this.database,
  });

  List<SingleChildWidget> providers() {
    return [
      Provider(create: (_) => config),
      Provider(create: (_) => database),
      Provider(create: (_) => _sideEffects()),
      BlocProvider(
          create: (_) => ReviewDataBloc(
                ReviewDataService(database),
                sideEffects: _sideEffects(),
              )),
    ];
  }

  SideEffects _sideEffects() {
    return kReleaseMode ? ProductionSideEffects() : DevSideEffects(config);
  }

  static Future<DiligenceContainer> start({
    String envFile = '.env',
    bool test = false,
  }) async {
    await dot_env.load(fileName: envFile);
    final config = DiligenceConfig.fromEnv(dot_env.env, test: test);
    sqflitePrepare();
    final database = await _setupDatabase(config.dbPath);
    return DiligenceContainer(
      config: config,
      database: database,
    );
  }

  static Future<Database> _setupDatabase(String path) async {
    final initialSchema = await loadAssetString('data/schema.sql');
    final manifestContent = await loadAssetString('AssetManifest.json');
    final Map<String, dynamic> manifestMap =
        castOrDefault<Map<String, dynamic>>(
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
}
