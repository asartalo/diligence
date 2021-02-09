import 'dart:io';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'helpers.dart';

// ignore_for_file: avoid_print

Future<void> bumpVersion(String newVersionTarget) async {
  final pubspecPath = findPubSpec();
  final pubspecFile = File(pubspecPath);
  final editor = YamlEditor(await pubspecFile.readAsString());
  final oldVersion = Version.parse(editor.parseAt(['version']).toString());
  if (oldVersion.build.isEmpty) {
    throw Exception(
        'Old version $oldVersion does not contain a correct build number');
  }
  final oldBuildNumber = oldVersion.build.first;
  if (oldBuildNumber is! int) {
    throw Exception(
        "Old version's build number ($oldBuildNumber) must be an integer");
  }
  final newVersion = Version.parse('$newVersionTarget+${oldBuildNumber + 1}');
  print('Updating pubspec version from $oldVersion to $newVersion');
  editor.update(['version'], newVersion.toString());
  await pubspecFile.writeAsString(editor.toString());
  print('DONE.');
}
