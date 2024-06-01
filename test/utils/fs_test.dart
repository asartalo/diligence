import 'dart:io';

import 'package:diligence/utils/fs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Fs', () {
    late Fs fs;

    setUp(() {
      fs = Fs();
    });

    group('fileExists()', () {
      test('should return true if file exists', () async {
        final result = await fs.fileExists('test/utils/fs_test.dart');
        expect(result, true);
      });

      test('should return false if file does not exist', () async {
        final result = await fs.fileExists('test/utils/fs_test_not_found.dart');
        expect(result, false);
      });
    });

    group('directoryExists()', () {
      test('should return true if directory exists', () async {
        final result = await fs.directoryExists('test/utils');
        expect(result, true);
      });

      test('should return false if directory does not exist', () async {
        final result = await fs.directoryExists('test/utils_not_found');
        expect(result, false);
      });
    });

    group('parentDirectory()', () {
      test('should return parent directory', () {
        final result = fs.parentDirectory('test/utils/fs_test.dart');
        expect(result, 'test/utils');
      });
    });

    group('contents()', () {
      test('should return file contents', () async {
        final result = await fs.contents('test/utils/fs_test.dart');
        expect(result.contains('void main()'), true);
      });
    });

    group('write()', () {
      setUp(() {
        final dir = Directory('test/tmp');
        if (!dir.existsSync()) {
          dir.createSync();
        } else {
          dir.listSync().forEach((file) {
            file.deleteSync();
          });
        }
      });

      test('should write contents to file', () async {
        const path = 'test/tmp/fs_test_write.dart';
        const contents = 'void main() {}';
        await fs.write(path, contents);
        final result = await fs.contents(path);
        expect(result, contents);
      });
    });
  });
}
