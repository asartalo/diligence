library conventional;

import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:pub_semver/pub_semver.dart';

part 'changelog.dart';
part 'commit.dart';
part 'commit_author.dart';
part 'version.dart';

const releasableCommitTypes = <String>{'feat', 'fix'};
bool hasReleasableCommits(List<Commit> commits) {
  for (final commit in commits) {
    if (releasableCommitTypes.contains(commit.type)) {
      return true;
    }
  }
  return false;
}
