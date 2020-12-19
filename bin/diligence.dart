import 'dart:io';

import 'package:args/args.dart';
import 'package:pub_release/pub_release.dart';
import 'package:yaml_edit/yaml_edit.dart';

// ignore_for_file: avoid_print
Future<void> main(List<String> arguments) async {
  exitCode = 0;

  try {
    final parser = ArgParser();
    parser.addCommand('bumpVersion');
    final command = parser.parse(arguments).command;
    if (command != null && command.name == 'bumpVersion') {
      if (command.rest.isEmpty) {
        throw Exception('Please provide the new version');
      }
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
      final newVersion =
          Version.parse('${command.rest.first}+${oldBuildNumber + 1}');
      print('Updating pubspec version from $oldVersion to $newVersion');
      editor.update(['version'], newVersion.toString());
      await pubspecFile.writeAsString(editor.toString());
      print('DONE.');
    } else {
      print('Hello!');
    }
  } catch (e) {
    exitCode = 1;
    stderr.writeln(e.toString());
    return;
  }
}
