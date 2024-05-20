import 'package:equatable/equatable.dart';

import 'diligence_config.dart';
import 'utils/fs.dart';

class ConfigValidator {
  final Fs fs;

  ConfigValidator(this.fs);

  Future<ConfigValidatorResult> validate(DiligenceConfig config) async {
    final parentDirectory = fs.parentDirectory(config.dbPath);
    final dbPathDirExists = await fs.directoryExists(parentDirectory);
    if (!dbPathDirExists) {
      return ConfigValidatorResult(
        false,
        'Database path directory "$parentDirectory" does not exist',
      );
    }

    return ConfigValidatorResult(true, 'Valid config file');
  }
}

class ConfigValidatorResult with EquatableMixin {
  final bool success;
  final String message;

  ConfigValidatorResult(this.success, this.message);

  @override
  List<Object?> get props => [success, message];
}
