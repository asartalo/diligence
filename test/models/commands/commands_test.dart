import 'package:diligence/models/commands/commands.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoOpCommand', () {
    test('should be a Command', () {
      expect(NoOpCommand(), isA<Command>());
    });

    test('it has at field', () {
      final before = DateTime.now();
      final command = NoOpCommand();
      final after = DateTime.now();
      expect(command.at.isAfter(before), isTrue);
      expect(command.at.isBefore(after), isTrue);
    });
  });
}
