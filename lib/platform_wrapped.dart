// PlatformWrapper exists because I hate that I can't pass Platform
// as a dependency... because all the usable stuff are STATIC methods.
import 'dart:io';

import 'package:meta/meta.dart';

// TODO: Extend this to create helper props like isSnap or isFlatpak
abstract class PlatformWrapped {
  String get operatingSystem;
  bool get isLinux;
  bool get isMacOS;
  bool get isWindows;
  bool get isAndroid;
  bool get isIOS;
  bool get isFuchsia;
  bool get isFlutterTest;
  Map<String, String> get environment;

  static PlatformWrapped instance() {
    return _ActualPlaformWrapped();
  }
}

@immutable
class _ActualPlaformWrapped extends PlatformWrapped {
  @override
  String get operatingSystem => throw UnimplementedError();

  @override
  Map<String, String> get environment => Platform.environment;

  @override
  bool get isAndroid => Platform.isAndroid;

  @override
  bool get isFuchsia => Platform.isFuchsia;

  @override
  bool get isIOS => Platform.isIOS;

  @override
  bool get isLinux => Platform.isLinux;

  @override
  bool get isMacOS => Platform.isMacOS;

  @override
  bool get isWindows => Platform.isWindows;

  @override
  bool get isFlutterTest => Platform.environment.containsKey('FLUTTER_TEST');
}
