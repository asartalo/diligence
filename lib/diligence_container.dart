// Diligence - A Task Management App
//
// Copyright (C) 2024 Wayne Duran <asartalo@gmail.com>
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// this program. If not, see <https://www.gnu.org/licenses/>.

import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dot_env;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'di.dart';
import 'diligence_config.dart';
import 'services/diligent.dart';
import 'services/review_data/review_data_bloc.dart';
import 'services/review_data_service.dart';
import 'services/side_effects.dart';
import 'utils/ticking_stub_clock.dart';

final loadAssetString = rootBundle.loadString;

class DiligenceContainer {
  final DiligenceConfig config;
  final Diligent diligent;
  final Di di;
  final bool test;

  DiligenceContainer({
    required this.config,
    required this.diligent,
    required this.di,
    this.test = false,
  });

  List<SingleChildWidget> providers() {
    return [
      Provider(create: (_) => config),
      Provider(create: (_) => diligent),
      Provider(create: (_) => di.clock),
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

  Future<void> resetDataForTests() async {
    if (test) {
      diligent.clearDataForTests();
    }
  }

  static bool showDbPath(DiligenceConfig config) =>
      !kReleaseMode && config.showDbPath;

  static Future<DiligenceContainer> start({
    String envFile = '.env',
    bool test = false,
  }) async {
    await dot_env.load(fileName: envFile);
    final config = getConfig(test);
    final pathToDb = await dbPath(test);
    if (showDbPath(config)) {
      // ignore: avoid_print
      print('Database path: $pathToDb');
    }
    final clock = test ? TickingStubClock() : const Clock();
    final di = Di(dbPath: pathToDb, isTest: test, clock: clock);
    final diligent = di.diligent;
    await diligent.runMigrations();
    await diligent.initialAreas(initialAreas);

    return DiligenceContainer(
      config: config,
      diligent: diligent,
      di: di,
      test: test,
    );
  }

  static DiligenceConfig getConfig(bool test) {
    if (test) {
      return DiligenceConfig.fromEnv(
        dot_env.env,
        showDbPath: false,
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
