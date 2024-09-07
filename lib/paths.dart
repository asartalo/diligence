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
import 'package:path/path.dart' as path;

String getScriptDir() {
  final scriptDir = path.dirname(Platform.script.path);
  final reg = RegExp(r'test$');

  if (reg.hasMatch(scriptDir)) {
    return path.dirname(scriptDir);
  }

  return scriptDir;
}

bool _isTest = Platform.environment.containsKey('FLUTTER_TEST');

// TODO: Needs testing in other platforms
String getHomeConfigDir() {
  if (Platform.isWindows || Platform.isAndroid) {
    return path.join(Platform.environment['APPDATA']!, 'Diligence');
  }

  if (Platform.isIOS) {
    return path.join(
      Platform.environment['HOME']!,
      'Library',
      'Application Support',
      'Diligence',
    );
  }

  if (Platform.isLinux) {
    return path.join(Platform.environment['HOME']!, '.config', 'diligence');
  }

  return path.join(Platform.environment['HOME']!, 'diligence');
}

// TODO: Consider if having a separate config file for test is necessary
String getUserConfigPath([String type = 'yaml']) {
  final suffix = kReleaseMode ? '' : (_isTest ? '.test' : '.dev');
  return path.join(getHomeConfigDir(), 'diligence$suffix.$type');
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
