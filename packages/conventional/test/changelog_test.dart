import 'dart:io';

import 'package:conventional/conventional.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as paths;

const chore = '''
commit fc9d8117b1074c3c965c5c1ccf845d784c026ac7
Author: Jane Doe <jane.doe@example.com>
Date:   Mon Feb 8 15:26:49 2021 +0800

    chore: clean up
''';

const docs = '''
commit fc9d8117b1074c3c965c5c1ccf845d784c026ac7
Author: Jane Doe <jane.doe@example.com>
Date:   Mon Feb 8 15:26:49 2021 +0800

    docs: you and me
''';

const fix = '''
commit cf6080079cd96cb4ccc2edca2ba9cacbcfd64704
Author: Jane Doe <jane.doe@example.com>
Date:   Sun Feb 7 12:58:06 2021 +0800

    fix: eat healthy (#3)
''';

const feat = '''
commit 925fcd38fe8bd2653ea70d67155b8e31082cf4b2
Author: Jane Doe <jane.doe@example.com>
Date:   Fri Feb 6 16:24:38 2021 +0800

    feat(movement): it jumps (#1)
''';

const feat2 = '''
commit a25fcd38fe8bd2653ea70d67155b8e31082cf4b2
Author: Jane Doe <jane.doe@example.com>
Date:   Fri Feb 6 16:24:38 2021 +0800

    feat(communication): it talks (#4)
''';

const feat3 = '''
commit a25fcd38fe8bd2653ea70d67155b8e31082cf4b2
Author: Jane Doe <jane.doe@example.com>
Date:   Fri Feb 5 16:24:38 2021 +0800

    feat(movement): it pounces (#2)
''';

const feat4 = '''
commit b25fcd38fe8bd2653ea70d67155b8e31082cf4b2
Author: Jane Doe <jane.doe@example.com>
Date:   Fri Feb 5 12:24:38 2021 +0800

    feat(communication): it sends sms (#5)
''';

const breaking = '''
commit 43cf9b78f77a0180ad408cb87e8a774a530619ce
Author: Jane Doe <jane.doe@example.com>
Date:   Fri Feb 1 11:56:26 2021 +0800

    feat!: null-safety (#6)
''';

final _startDir = Directory.current.path;
final _tmpDir = paths.join(_startDir, 'tmp');

bool _exists(String path) {
  return FileSystemEntity.typeSync(path) != FileSystemEntityType.notFound;
}

void main() {
  group('updateChangelog()', () {
    Directory tmpDir = Directory(_tmpDir);
    String changelogFilePath = paths.join(_tmpDir, 'CHANGELOG.md');
    final now = DateTime.parse('2021-02-09 12:00:00');
    const version = '1.0.0';
    late List<Commit> commits;

    setUpAll(() async {
      if (!(await tmpDir.exists())) {
        await tmpDir.create();
      }
    });

    tearDown(() async {
      if (_exists(changelogFilePath)) {
        await File(changelogFilePath).delete();
      }
    });

    tearDownAll(() async {
      if (await tmpDir.exists()) {
        await tmpDir.delete();
      }
    });

    group('when CHANGELOG should not be generated or updated', () {
      final Map<String, List<String>> noChangeLogs = {
        'there are no updates': [],
        'there are no releasable updates': [chore, docs],
      };

      noChangeLogs.forEach((condition, commitsStrings) {
        final setupFunction = () async {
          commits = Commit.parseCommitsStringList(commitsStrings);
          await writeChangelog(
            commits: commits,
            changelogFilePath: changelogFilePath,
            version: version,
            now: now,
          );
        };

        group('if $condition', () {
          group('if there is no changelog file yet', () {
            setUp(() async {
              await setupFunction();
            });

            test('does not create a changelog if $condition', () async {
              expect(_exists(changelogFilePath), false);
            });
          });

          group('if there is an existing changelog file', () {
            setUp(() async {
              File file = File(changelogFilePath);
              await file.writeAsString('');
              await setupFunction();
            });

            test('does not update a file if $condition', () async {
              final file = File(changelogFilePath);
              expect(await file.readAsString(), equals(''));
            });
          });
        });
      });
    });

    group('when CHANGELOG can be generated or updated', () {
      final Map<String, _Test> testData = {
        'all stuff': _Test(
          [chore, docs, fix, feat, feat2, feat3, feat4, breaking],
          '''
# 1.0.0 (2021-02-09)

## Bug Fixes

- eat healthy ([#3](issues/3)) ([cf60800](commit/cf60800))

## Features

- **movement:** it jumps ([#1](issues/1)) ([925fcd3](commit/925fcd3))
- **movement:** it pounces ([#2](issues/2)) ([a25fcd3](commit/a25fcd3))
- **communication:** it talks ([#4](issues/4)) ([a25fcd3](commit/a25fcd3))
- **communication:** it sends sms ([#5](issues/5)) ([b25fcd3](commit/b25fcd3))

## BREAKING CHANGES

- null-safety ([#6](issues/6)) ([43cf9b7](commit/43cf9b7))
''',
        ),
      };

      testData.forEach((key, data) {
        final setupProper = () async {
          commits = Commit.parseCommitsStringList(data.commits);
          await writeChangelog(
            commits: commits,
            changelogFilePath: changelogFilePath,
            version: version,
            now: now,
          );
        };

        group('$key and no changelog file yet', () {
          setUp(() async {
            await setupProper();
          });

          test('writes the changelog file', () {
            expect(_exists(changelogFilePath), true);
          });

          test('writes changelog contents to the file', () async {
            final contents = await File(changelogFilePath).readAsString();
            expect(contents, equals(data.content));
          });
        });

        group('$key and a changelog file already exists', () {
          setUp(() async {
            final file = File(changelogFilePath);
            await file.writeAsString('Hello world.\n');
            await setupProper();
          });

          test('writes changelog contents to the file', () async {
            final contents = await File(changelogFilePath).readAsString();
            expect(contents, equals('${data.content}\nHello world.\n'));
          });
        });
      });
    });
  });
}

class _Test {
  final List<String> commits;
  final String content;
  final String before;

  const _Test(this.commits, this.content, {this.before = ''});
}
