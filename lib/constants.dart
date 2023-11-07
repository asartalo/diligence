import 'dart:io';

import 'package:path/path.dart' as path;

const kDefaultMaxIdleMinutes = 30;

String getScriptDir() {
  final scriptDir = path.dirname(Platform.script.path);
  final reg = RegExp(r'test$');
  if (reg.hasMatch(scriptDir)) {
    return path.dirname(scriptDir);
  }
  return scriptDir;
}

var _scriptDir = getScriptDir();
final _rootPathVal = _scriptDir;
final _testPathVal = path.join(_scriptDir, 'test');
final _libPathVal = path.join(_scriptDir, 'lib');

// Project paths
class Paths {
  // Do not instantiate
  Paths._();

  static final String root = _rootPathVal;
  static final String test = _testPathVal;
  static final String lib = _libPathVal;
  static final String testTmp = path.join(_testPathVal, 'tmp');
}
