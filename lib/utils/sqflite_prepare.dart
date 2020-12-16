import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

bool _prepDone = false;

void sqflitePrepare() {
  if (_prepDone) {
    return;
  }
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    _prepDone = true;
  }
}
