part of 'conventional.dart';

Future<bool> writeChangelog({
  required List<Commit> commits,
  required String changelogFilePath,
  required String version,
  required DateTime now,
}) async {
  if (hasReleasableCommits(commits)) {
    final file = File(changelogFilePath);
    String oldContents = '';
    if (await file.exists()) {
      oldContents = (await file.readAsString()).trim();
    }
    final content = _writeContents(commits, version, now);
    await file.writeAsString(
        oldContents.isEmpty ? content : '$content\n$oldContents\n');
  }
  return false;
}

class _CommitSections {
  final List<Commit> bugFixes = [];
  final List<Commit> features = [];
  final List<Commit> breakingChanges = [];
}

String _commitLink(Commit commit) {
  final hash = commit.id.substring(0, 7);
  return '([$hash](commit/$hash))';
}

final _issueRegexp = RegExp(r'\#(\d+)');
String _linkIssues(String description) {
  return description.replaceAllMapped(_issueRegexp, (match) {
    final issueNumber = match.group(1);
    return '[#$issueNumber](issues/$issueNumber)';
  });
}

String _formatLog(Commit commit) {
  final scopePart = commit.scope.isEmpty ? '' : '**${commit.scope}:** ';
  return '- $scopePart${_linkIssues(commit.description)} ${_commitLink(commit)}';
}

String? _commitSection(String header, List<Commit> commits) {
  if (commits.isEmpty) {
    return null;
  }
  commits.sort((a, b) {
    if (a.scope == b.scope) {
      return a.scope.compareTo(b.scope);
    }
    return a.date.compareTo(b.date);
  });
  final contents = commits.map(_formatLog).toList().join('\n');
  return '## $header\n\n$contents';
}

String _writeContents(List<Commit> commits, String version, DateTime now) {
  final logs = _CommitSections();
  for (final commit in commits) {
    if (commit.breaking) {
      logs.breakingChanges.add(commit);
    } else if (commit.type == 'fix') {
      logs.bugFixes.add(commit);
    } else if (commit.type == 'feat') {
      logs.features.add(commit);
    }
  }
  final List<String> sections = [
    _versionHeadline(version, now),
    _commitSection('Bug Fixes', logs.bugFixes),
    _commitSection('Features', logs.features),
    _commitSection('BREAKING CHANGES', logs.breakingChanges),
  ].whereType<String>().toList();

  return '${sections.join('\n\n').trim()}\n';
}

String _versionHeadline(String version, DateTime now) {
  final date = '${now.year}-${_zeroPad(now.month)}-${_zeroPad(now.day)}';
  return '# $version ($date)';
}
