import 'package:conventional/conventional.dart';

import './helpers.dart';

// ignore_for_file: avoid_print

Future<String> shouldRelease(String tag) async {
  final lastHash =
      tag.isEmpty ? await getFirstHash() : await getHashForTag(tag);
  final commitLogs = await getCommitLogsFrom(lastHash);
  final commits = Commit.parseCommits(commitLogs);
  return hasReleasableCommits(commits) ? 'yes' : 'no';
}
