import 'package:diligence/models/commands/commands.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/between_dates_matcher.dart';

void main() {
  group('NoOpCommand', () {
    test('should be a Command', () {
      expect(NoOpCommand(), isA<Command>());
    });

    test('it has at field', () {
      final before = DateTime.now().subtract(const Duration(milliseconds: 1));
      final command = NoOpCommand();
      final after = DateTime.now().add(const Duration(milliseconds: 1));
      expect(command.at, isBetweenDates(before, after));
    });
  });
}
