import 'package:pub_semver/pub_semver.dart';

final _fullVersion = Version.parse('0.1.7+8');

class AppInfo {
  static Version version = Version(
    _fullVersion.major,
    _fullVersion.minor,
    _fullVersion.patch,
  );
}
