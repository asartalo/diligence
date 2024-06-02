import 'dart:io';

import 'package:diligence/utils/fs.dart';

class StubFs implements Fs {
  final Map<String, String> _files = {};
  final Set<String> _directories = {};

  void addFile(String path, String contents) {
    _files[path] = contents;
    _directories.add(parentDirectory(path));
  }

  void addDirectory(String path) {
    _directories.add(path);
  }

  @override
  Future<bool> fileExists(String path) async {
    return _files.containsKey(path);
  }

  @override
  Future<bool> directoryExists(String path) async {
    return _directories.contains(path);
  }

  @override
  String parentDirectory(String path) => Directory(path).parent.path;

  @override
  Future<String> contents(String path) async {
    return _files[path]!;
  }

  @override
  Future<void> write(String path, String contents) async {
    _files[path] = contents;
  }
}
