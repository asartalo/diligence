import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/foundation.dart';

import '../config_validator.dart';
import '../di_scope_cache.dart';
import '../platform_wrapped.dart';
import '../services/config_file_paths.dart';
import '../services/config_manager.dart';
import '../services/logger/log_observable.dart';
import '../utils/clock.dart';
import '../utils/fs.dart';

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
  })  : clock = clock ?? Clock(),
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
          ));

  Fs get fs => _cache.getSet(#fs, () => Fs(fileSystem));

  ConfigValidator get validator => _cache.getSet(
        #validator,
        () => ConfigValidator(fs),
      );

  LogObservable get configManagerLogger =>
      _cache.getSet(#logger, () => LogObservable('ConfigManager'));

  ConfigFilePaths get configFilePaths => _cache.getSet(
      #configFilePaths, () => ConfigFilePaths(fs: fs, platform: platform));
}
