import 'dart:io';

// File system utilities
abstract class Fs {
  factory Fs() => const _Fs();

  Future<bool> fileExists(String path);
  Future<bool> directoryExists(String path);
  String parentDirectory(String path);
  Future<String> contents(String path);
  Future<void> write(String path, String contents);
}

class _Fs implements Fs {
  const _Fs();

  @override
  Future<bool> fileExists(String path) => File(path).exists();

  @override
  String parentDirectory(String path) => Directory(path).parent.path;

  @override
  Future<bool> directoryExists(String path) => Directory(path).exists();

  @override
  Future<String> contents(String path) => File(path).readAsString();

  @override
  Future<void> write(String path, String contents) =>
      File(path).writeAsString(contents);
}
