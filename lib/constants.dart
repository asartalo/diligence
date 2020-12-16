import 'dart:io';

import 'package:path/path.dart' as path;

class ProjectPaths {
  static final ProjectPaths _instance = ProjectPaths._internal();
  String _rootPath;
  String _testPath;

  static ProjectPaths get instance => _instance;

  String get rootPath => _rootPath;
  String get testPath => _testPath;

  ProjectPaths._internal() {
    var _scriptDir = path.dirname(Platform.script.path);
    final _regExp = RegExp(r'test$');
    if (_regExp.hasMatch(_scriptDir)) {
      _scriptDir = path.dirname(_scriptDir);
    }
    _rootPath = _scriptDir;
    _testPath = path.join(_scriptDir, 'test');
  }
}