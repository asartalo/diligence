import 'helpers.dart';

// ignore_for_file: avoid_print

final projectRoot = findProjectRoot();

final testReg = RegExp(r'\s(\w+)');
String parseKind(String line) {
  final match = testReg.firstMatch(line.trim());
  if (match is RegExpMatch) {
    return match.group(1) ?? '';
  }
  return '';
}

Set<String> parseKindsOfCommit(String logOutput) {
  final commitKinds = logOutput
      .split('\n')
      .map((String line) => parseKind(line.trim()))
      .toList();
  return Set<String>.from(commitKinds);
}

bool hasReleasableCommits(Set<String> commits) {
  return commits.contains('feat') || commits.contains('fix');
}

Future<String> getCommitLogsFrom(String lastHash) async {
  final result = await execute(
    'git',
    '--no-pager log $lastHash..HEAD --oneline --no-decorate'.split(' '),
    projectRoot,
  );

  if (result.success) {
    return result.output;
  }

  print(result.output);
  return '';
}

Future<String> getHashForTag(String tag) async {
  // git rev-parse beforeFeat^{}
  final result = await execute(
    'git',
    'rev-parse $tag^{}'.split(' '),
    projectRoot,
  );

  if (result.success) {
    return result.output;
  }

  print(result.output);
  return '';
}

Future<String> shouldRelease(String tag) async {
  if (tag.isEmpty) {
    return 'no';
  }
  final lastHash = await getHashForTag(tag);
  final result = await getCommitLogsFrom(lastHash);
  final kindsUnique = parseKindsOfCommit(result);
  return hasReleasableCommits(kindsUnique) ? 'yes' : 'no';
}
