import 'package:file/file.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

import '../utils/fs.dart';

@immutable
class Viability {
  final bool viable;
  final String reason;

  const Viability(this.viable, this.reason);
}

class FileWriteViabilityChecker {
  final Fs fs;
  final String subPath;

  // This is the path which we don't have control over and we shouldn't try to create if it doesn't exist
  final String unOwnedParentPath;

  String get fullPath => path.join(unOwnedParentPath, subPath);

  Viability? _viability;

  FileWriteViabilityChecker({
    required this.fs,
    required this.unOwnedParentPath,
    required this.subPath,
  });

  Future<Viability> checkViability() async {
    if (_viability != null) {
      return _viability!;
    }

    // final unOwnedParentDirectory = fs.directory(unOwnedParentPath);
    if (!await fs.directoryExists(unOwnedParentPath)) {
      // The directory we are supposed to be under does not even exist.
      _viability = Viability(
        false,
        "The un-owned parent directory `$unOwnedParentPath` does not exist.",
      );
      return _viability!;
    }

    final parentPath = fs.parentDirectory(fullPath);
    if (!await fs.directoryExists(parentPath)) {
      try {
        // Since the unOwnedParentDirectory exists, we can safely attempt
        // recursively creating the parent directory
        await fs.createDirectory(parentPath, recursive: true);
      } on FileSystemException catch (e) {
        _viability = Viability(
          false,
          "Parent directory `$parentPath` does not exist. Attempted to create it but got the exception: \"${e.message}\"",
        );
        return _viability!;
      }
    }

    if (!await fs.fileExists(fullPath)) {
      try {
        await fs.createFile(fullPath);
      } on FileSystemException catch (e) {
        _viability = Viability(
          false,
          "File `$fullPath` did not exist and could not be created with the following exception: \"${e.message}\"",
        );
        return _viability!;
      }

      // We were able to create the file so we assume it's viable
      _viability = Viability(true, 'File is available for writing.');
      return _viability!;
    }

    // Check if file can be written
    try {
      final writeFs = await fs.fileOpen(fullPath, mode: FileMode.append);
      await writeFs.close();
      _viability = Viability(true, 'File is available for writing.');
    } on FileSystemException catch (e) {
      _viability = Viability(
        false,
        "Unable to open file `$fullPath` for writing (append check failed): ${e.message}",
      );
    }

    return _viability!;
  }
}
