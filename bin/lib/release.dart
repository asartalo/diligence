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

Future<void> _writeNewVersion(String directory, Version version) async {
  final file = File(paths.join(directory, 'NEWVERSION.txt'));
  await file.writeAsString('v$version');
}

Future<void> _writeSummary(String directory, ChangeSummary summary) async {
  final file = File(paths.join(directory, 'SUMMARY.md'));
  await file.writeAsString(summary.toMarkdown());
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
  final cleanVersion = buildlessVersion(newVersion);
  // Bump version
  print('Updating pubspec version from $currentVersion to $newVersion');
  bumpPubspecVersion(newVersion);
  // Write changelog
  final changelogFile = paths.join(paths.dirname(pubspecPath), 'CHANGELOG.md');
  print('Updating CHANGELOG.md');
  final summary = await writeChangelog(
    version: cleanVersion.toString(),
    commits: commits,
    now: DateTime.now(),
    changelogFilePath: changelogFile,
  );

  if (summary == null) {
    print('No changelogs written.');
    return;
  }

  // Write new version to NEWVERSION.txt
  final dirname = paths.dirname(changelogFile);
  print('Writing "NEWVERSION.txt" with $cleanVersion');
  await _writeNewVersion(dirname, cleanVersion);
  print('Writing "SUMMARY.md"');
  await _writeSummary(dirname, summary);
}
