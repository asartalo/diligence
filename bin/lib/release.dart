// ignore_for_file: avoid_print
import 'dart:io';

import 'package:conventional/conventional.dart';
import 'package:path/path.dart' as paths;
import 'package:pub_semver/pub_semver.dart';
import 'package:version_bump/version_bump.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'helpers.dart';

final pubspecPath = findPubSpec();
final pubspecFile = File(pubspecPath);

Future<Version> getCurrentVersion() async {
  final editor = YamlEditor(await pubspecFile.readAsString());
  final versionOnFile = editor.parseAt(['version'])?.value;
  if (versionOnFile is String) {
    return Version.parse(versionOnFile);
  }
  throw Exception(
      'Unable to find version on pubspec.yaml. Found "$versionOnFile".');
}

Future<void> bumpPubspecVersion(Version newVersion) async {
  final editor = YamlEditor(await pubspecFile.readAsString());
  editor.update(['version'], newVersion.toString());
  await pubspecFile.writeAsString(editor.toString());
  print('DONE.');
}

Future<void> release(String tag) async {
  print('Releasing...');
  final lastHash =
      tag.isEmpty ? await getFirstHash() : await getHashForTag(tag);
  final commits = Commit.parseCommits(await getCommitLogsFrom(lastHash));
  if (!hasReleasableCommits(commits)) {
    print('No releasable commits found since $lastHash');
    print('Skipping release.');
    return;
  }

  // Get current version
  final currentVersion = await getCurrentVersion();
  // Calculate new version
  final newVersion = nextVersion(currentVersion, commits);
  // Bump version
  print('Updating pubspec version from $currentVersion to $newVersion');
  bumpPubspecVersion(newVersion);
  // Write changelog
  final changelogFile = paths.join(paths.dirname(pubspecPath), 'CHANGELOG.md');
  await writeChangelog(
    version: newVersion.toString(),
    commits: commits,
    now: DateTime.now(),
    changelogFilePath: changelogFile,
  );
  // Update pubspec.yaml
}
