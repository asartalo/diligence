// Diligence - A Task Management App
//
// Copyright (C) 2025 Wayne Duran <asartalo@gmail.com>
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

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/foundation.dart';

import '../config_validator.dart';
import '../di_scope_cache.dart';
import '../platform_wrapped.dart';
import '../services/config_file_paths.dart';
import '../services/config_manager.dart';
import '../services/file_write_viability_checker.dart';
import '../services/logger/log_observable.dart';
import '../utils/clock.dart';
import '../utils/fs.dart';
import '../utils/stub_clock.dart';

mixin Scope {}

@immutable
class RootScope {
  final Clock clock;
  final FileSystem fileSystem;
  final PlatformWrapped platform;
  final bool isTest;

  final DiScopeCache _cache;

  RootScope({
    Clock? clock,
    FileSystem? fileSystem,
    PlatformWrapped? platform,
    this.isTest = false,
  }) : clock = clock ?? (isTest ? StubClock() : Clock()),
       fileSystem = fileSystem ?? LocalFileSystem(),
       platform = platform ?? PlatformWrapped.instance(),
       _cache = DiScopeCache();

  ConfigManager get configManager => _cache.getSet(
    #configManager,
    () => ConfigManager(
      fs,
      validator,
      configFilePaths: configFilePaths,
      logger: configManagerLogger,
      test: isTest,
    ),
  );

  Fs get fs => _cache.getSet(#fs, () => Fs(fileSystem));

  ConfigValidator get validator =>
      _cache.getSet(#validator, () => ConfigValidator(fs));

  LogObservable get configManagerLogger =>
      _cache.getSet(#logger, () => LogObservable('ConfigManager'));

  List<FileWriteViabilityChecker> get configFilePaths => _cache
      .getSet(
        #configFilePaths,
        () => ConfigFilePaths(fs: fs, platform: platform),
      )
      .getProbableConfigFilePaths();
}
