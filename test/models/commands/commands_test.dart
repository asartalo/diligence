import 'package:diligence/models/commands/commands.dart';
import 'package:diligence/utils/clock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoOpCommand', () {
    final clock = Clock();

    test('should be a Command', () {
      expect(NoOpCommand(at: clock.now()), isA<Command>());
    });

    test('it has at field', () {
      final now = clock.now();
      final command = NoOpCommand(at: now);
      expect(command.at, now);
    });
  });
}
