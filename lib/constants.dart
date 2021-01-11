import 'dart:io';

import 'package:path/path.dart' as path;

const kDefaultMaxIdleMinutes = 30;

class ProjectPaths {
  static final ProjectPaths _instance = ProjectPaths._internal();
  String _rootPath;
  String _testPath;
  String _libPath;

  static ProjectPaths get instance => _instance;

  String get root => _rootPath;
  String get test => _testPath;
  String get lib => _libPath;

  ProjectPaths._internal() {
    var _scriptDir = path.dirname(Platform.script.path);
    final _regExp = RegExp(r'test$');
    if (_regExp.hasMatch(_scriptDir)) {
      _scriptDir = path.dirname(_scriptDir);
    }
    _rootPath = _scriptDir;
    _testPath = path.join(_scriptDir, 'test');
    _libPath = path.join(_scriptDir, 'lib');
  }
}
