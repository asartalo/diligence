library conventional;

import 'dart:io';

import 'package:equatable/equatable.dart';

part 'changelog.dart';
part 'commit.dart';
part 'commit_author.dart';

const releasableCommitTypes = <String>{'feat', 'fix'};
bool hasReleasableCommits(List<Commit> commits) {
  for (final commit in commits) {
    if (releasableCommitTypes.contains(commit.type)) {
      return true;
    }
  }
  return false;
}
