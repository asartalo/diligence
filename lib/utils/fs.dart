import 'package:file/file.dart';
import 'package:meta/meta.dart';

// File system utilities
abstract class Fs {
  factory Fs(FileSystem fs) => _Fs(fs);

  Future<bool> fileExists(String path);
  Future<bool> directoryExists(String path);
  String parentDirectory(String path);
  Future<String> contents(String path);
  Future<void> write(String path, String contents);
  Future<RandomAccessFile> fileOpen(String path,
      {FileMode mode = FileMode.read});
  Future<Directory> createDirectory(String path, {bool recursive = false});
  Future<File> createFile(String path,
      {bool recursive = false, bool exclusive = false});
}

@immutable
class _Fs implements Fs {
  final FileSystem fileSystem;

  const _Fs(this.fileSystem);

  @override
  Future<bool> fileExists(String path) => fileSystem.file(path).exists();

  @override
  String parentDirectory(String path) => fileSystem.directory(path).parent.path;

  @override
  Future<bool> directoryExists(String path) =>
      fileSystem.directory(path).exists();

  @override
  Future<String> contents(String path) => fileSystem.file(path).readAsString();

  @override
  Future<void> write(String path, String contents) =>
      fileSystem.file(path).writeAsString(contents);

  @override
  Future<RandomAccessFile> fileOpen(String path,
          {FileMode mode = FileMode.read}) =>
      fileSystem.file(path).open(mode: mode);

  @override
  Future<Directory> createDirectory(String path, {bool recursive = false}) {
    return fileSystem.directory(path).create(recursive: recursive);
  }

  @override
  Future<File> createFile(
    String path, {
    bool recursive = false,
    bool exclusive = false,
  }) {
    return fileSystem
        .file(path)
        .create(recursive: recursive, exclusive: exclusive);
  }
}
