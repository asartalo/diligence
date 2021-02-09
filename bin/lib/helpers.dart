import 'dart:io';
import 'package:path/path.dart' as paths;

// ignore_for_file: avoid_print

bool exists(String path) {
  return FileSystemEntity.typeSync(path) != FileSystemEntityType.notFound;
}

final rootPath = Platform.pathSeparator;

String findPubSpec() {
  final startingDir = Directory.current.path;
  const pubspecName = 'pubspec.yaml';
  var cwd = startingDir;
  var found = true;

  var pubspecPath = paths.join(cwd, pubspecName);
  // climb the path searching for the pubspec
  while (!exists(pubspecPath)) {
    cwd = paths.dirname(cwd);
    // Have we found the root?
    if (cwd == rootPath) {
      found = false;
      break;
    }
    pubspecPath = paths.join(cwd, pubspecName);
  }

  if (!found) {
    print('Unable to find pubspec.yaml, run release from the '
        "package's root directory.");
    exit(-1);
  }
  return paths.canonicalize(pubspecPath);
}

String findProjectRoot() {
  final pubspecPath = findPubSpec();
  return paths.dirname(pubspecPath);
}

class Execution {
  final bool success;
  final String output;

  const Execution({
    required this.success,
    required this.output,
  });
}

Future<Execution> execute(String cmd, List<String> args, String cwd) async {
  bool success = false;
  String output;
  try {
    final result = await Process.run(
      cmd,
      args,
      workingDirectory: cwd,
    );
    final exitCode = result.exitCode;
    if (exitCode != 0) {
      output = result.stdout.toString();
      output += 'Command executed code: $exitCode';
      success = false;
    } else {
      output = result.stdout.toString().trim();
      success = true;
    }
  } catch (e, stacktrace) {
    output = '$e\n\n$stacktrace';
    success = false;
  }
  return Execution(
    success: success,
    output: output,
  );
}
