import 'dart:io';

import 'package:args/args.dart';

import 'lib/bump_version.dart';
import 'lib/release.dart';
import 'lib/should_release.dart';

// ignore_for_file: avoid_print
Future<void> main(List<String> arguments) async {
  exitCode = 0;

  try {
    final parser = ArgParser();
    parser.addCommand('bumpVersion');
    parser.addCommand('shouldRelease');
    parser.addCommand('release');
    final command = parser.parse(arguments).command;
    if (command.name == 'bumpVersion') {
      if (command.rest.isEmpty) {
        throw Exception('Please provide the new version');
      }
      await bumpVersion(command.rest.first);
    } else if (command.name == 'shouldRelease') {
      final tag = command.rest.isEmpty ? '' : command.rest.first;
      print(await shouldRelease(tag));
    } else if (command.name == 'release') {
      final tag = command.rest.isEmpty ? '' : command.rest.first;
      await release(tag);
    } else {
      print('Hello!');
    }
  } catch (e) {
    exitCode = 1;
    stderr.writeln(e.toString());
    return;
  }
}
