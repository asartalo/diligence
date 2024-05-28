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

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'config_validator.dart';
import 'di.dart';
import 'diligence_config.dart';
import 'services/config_manager.dart';
import 'services/diligent.dart';
import 'services/review_data/review_data_bloc.dart';
import 'services/review_data_service.dart';
import 'services/side_effects.dart';
import 'utils/clock.dart';
import 'utils/fs.dart';
import 'utils/stub_clock.dart';

final loadAssetString = rootBundle.loadString;
bool _dbDisplayedAlready = false;

class DiligenceContainer {
  final ConfigManager configManager;
  final DiligenceConfig config;
  final Diligent diligent;
  final Di di;
  final bool test;

  DiligenceContainer({
    required this.config,
    required this.diligent,
    required this.di,
    required this.configManager,
    this.test = false,
  });

  List<SingleChildWidget> providers() {
    return [
      Provider(create: (_) => config),
      Provider(create: (_) => diligent),
      Provider(create: (_) => di.clock),
      Provider(create: (_) => _sideEffects()),
      Provider(create: (_) => di.noticeQueue),
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
      !kReleaseMode && !_dbDisplayedAlready && config.showDbPath;

  static Future<DiligenceContainer> containerStart({bool test = false}) async {
    final pathToDb = await dbPath(test);
    final clock = test ? StubClock() : Clock();
    final fs = Fs();
    final ConfigValidator validator = ConfigValidator(fs);
    final configManager = ConfigManager(fs, validator);
    final config = await getConfig(configManager, test, pathToDb);
    final di = Di(config: config, isTest: test, clock: clock);
    if (showDbPath(config)) {
      // ignore: avoid_print
      print('Database path: ${config.dbPath}');
      _dbDisplayedAlready = true;
    }
    if (test) {
      await deleteDb(pathToDb);
    }

    final container = DiligenceContainer(
      configManager: configManager,
      config: config,
      diligent: di.diligent,
      di: di,
      test: test,
    );
    await container.start();

    return container;
  }

  Future<DiligenceContainer> reloadContainer() async {
    await stop();
    return containerStart(test: test);
  }

  Future<void> start() async {
    await diligent.runMigrations();
    await diligent.initialAreas(initialAreas);
    di.jobQueue.registerEventHandlers(diligent);
    await di.jobTrack.start();
  }

  Future<void> stop() async {
    await di.jobTrack.stop();
    await di.db.close();
  }

  static Future<DiligenceConfig> getConfig(
    ConfigManager configManager,
    bool test,
    String dbPath,
  ) async {
    final result = await configManager.loadConfig(
      dbPath: dbPath,
      showDbPath: !kReleaseMode,
      showReviewPage: test,
    );
    return result.unwrap();
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

  static Future<void> deleteDb(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
