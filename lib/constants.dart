import 'dart:io';

import 'package:path/path.dart' as path;

const kDefaultMaxIdleMinutes = 30;

String getScriptDir() {
  final _scriptDir = path.dirname(Platform.script.path);
  final _reg = RegExp(r'test$');
  if (_reg.hasMatch(_scriptDir)) {
    return path.dirname(_scriptDir);
  }
  return _scriptDir;
}

var _scriptDir = getScriptDir();
final _rootPathVal = _scriptDir;
final _testPathVal = path.join(_scriptDir, 'test');
final _libPathVal = path.join(_scriptDir, 'lib');

class ProjectPaths {
  static final ProjectPaths _instance = ProjectPaths._internal();
  late final String _rootPath = _rootPathVal;
  late final String _testPath = _testPathVal;
  late final String _libPath = _libPathVal;

  static ProjectPaths get instance => _instance;

  String get root => _rootPath;
  String get test => _testPath;
  String get lib => _libPath;

  ProjectPaths._internal();
}
