import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dot_env;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'diligence_config.dart';
import 'services/diligent.dart';
import 'services/review_data/review_data_bloc.dart';
import 'services/review_data_service.dart';
import 'services/side_effects.dart';

final loadAssetString = rootBundle.loadString;

class DiligenceContainer {
  final DiligenceConfig config;
  final Diligent diligent;

  DiligenceContainer({
    required this.config,
    required this.diligent,
  });

  List<SingleChildWidget> providers() {
    return [
      Provider(create: (_) => config),
      Provider(create: (_) => diligent),
      Provider(create: (_) => _sideEffects()),
      BlocProvider(
        create: (_) => ReviewDataBloc(
          ReviewDataService(),
          sideEffects: _sideEffects(),
        ),
      ),
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
    final config = getConfig(test);
    final pathToDb = await dbPath(test);
    if (!kReleaseMode && config.showDbPath) {
      // ignore: avoid_print
      print('Database path: $pathToDb');
    }
    final diligent = test ? Diligent.forTests() : Diligent(path: pathToDb);
    await diligent.runMigrations();
    await diligent.initialAreas(initialAreas);

    return DiligenceContainer(
      config: config,
      diligent: diligent,
    );
  }

  static DiligenceConfig getConfig(bool test) {
    if (test) {
      return DiligenceConfig.fromEnv(
        dot_env.env,
        showDbPath: true,
        showReviewPage: true,
      );
    }

    return DiligenceConfig.fromEnv(dot_env.env);
  }

  static Future<Directory> getApplicationDirectory() =>
      Platform.isIOS ? getLibraryDirectory() : getApplicationSupportDirectory();

  static String dbName(bool test) => test
      ? 'diligence_test.db'
      : (kReleaseMode ? 'diligence.db' : 'diligence_dev.db');

  static Future<String> dbPath(bool test) async {
    final directory = await getApplicationDirectory();
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return path.join(directory.path, dbName(test));
  }
}
