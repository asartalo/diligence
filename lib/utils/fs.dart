import 'dart:io';

// File system utilities
abstract class Fs {
  factory Fs() => const _Fs();

  Future<bool> exists(String path);
  Future<String> contents(String path);
}

class _Fs implements Fs {
  const _Fs();

  @override
  Future<bool> exists(String path) => File(path).exists();

  @override
  Future<String> contents(String path) => File(path).readAsString();
}
