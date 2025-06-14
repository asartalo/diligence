import 'package:file/file.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import '../platform_wrapped.dart';
import '../utils/fs.dart';
import 'file_write_viability_checker.dart';

typedef _FWVCs = List<FileWriteViabilityChecker>;

@immutable
class ConfigFile {
  final FileSystem fs;
  final String fullPath;

  const ConfigFile({required this.fs, required this.fullPath});
}

class ConfigFilePaths {
  final Fs fs;
  final PlatformWrapped platform;
  _FWVCs? _locations;

  String get _configFileName {
    final suffix =
        kReleaseMode ? '' : (platform.isFlutterTest ? '.test' : '.dev');
    return 'diligence$suffix.yaml';
  }

  ConfigFilePaths({required this.fs, required this.platform});

  List<FileWriteViabilityChecker> getProbableConfigFilePaths() {
    if (_locations == null) {
      final _FWVCs locations = [];
      if (platform.isWindows || platform.isAndroid) {
        _addWindowsAndAndroidCFLs(locations);
      } else if (platform.isIOS) {
        _addIosCFLs(locations);
      } else if (platform.isLinux) {
        if (platform.environment['SNAP_NAME'] == 'diligence') {
          _addLinuxSnapCFLs(locations);
        }
        _addLinuxCFLs(locations);
      }

      // Default
      _addDefaultCFLs(locations);
      _locations = locations;
    }

    return _locations!;
  }

  void _addWindowsAndAndroidCFLs(_FWVCs locations) {
    locations.add(
      FileWriteViabilityChecker(
        fs: fs,
        unOwnedParentPath: path.join(
          platform.environment['APPDATA']!,
          'Diligence',
        ),
        subPath: _configFileName,
      ),
    );
  }

  void _addIosCFLs(_FWVCs locations) {
    locations.add(
      FileWriteViabilityChecker(
        fs: fs,
        unOwnedParentPath: path.join(
          platform.environment['HOME']!,
          'Library',
          'Application Support',
          'Diligence',
        ),
        subPath: _configFileName,
      ),
    );
  }

  void _addLinuxSnapCFLs(_FWVCs locations) {
    locations.add(
      FileWriteViabilityChecker(
        fs: fs,
        unOwnedParentPath: platform.environment['SNAP_REAL_HOME']!,
        subPath: path.join(
          '.config',
          'diligence',
          _configFileName,
        ),
      ),
    );

    locations.add(
      FileWriteViabilityChecker(
        fs: fs,
        unOwnedParentPath: path.join(
          platform.environment['SNAP_REAL_HOME']!,
          '.config',
        ),
        subPath: path.join('diligence', _configFileName),
      ),
    );

    locations.add(
      FileWriteViabilityChecker(
        fs: fs,
        unOwnedParentPath: platform.environment['HOME']!,
        subPath: _configFileName,
      ),
    );
  }

  void _addLinuxCFLs(_FWVCs locations) {
    locations.add(
      FileWriteViabilityChecker(
        fs: fs,
        unOwnedParentPath: platform.environment['HOME']!,
        subPath: path.join(
          '.config',
          'diligence',
          _configFileName,
        ),
      ),
    );
  }

  void _addDefaultCFLs(_FWVCs locations) {
    locations.add(
      FileWriteViabilityChecker(
        fs: fs,
        unOwnedParentPath: platform.environment['HOME']!,
        subPath: path.join(
          _configFileName,
        ),
      ),
    );
  }
}
