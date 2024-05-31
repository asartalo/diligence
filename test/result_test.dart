import 'package:diligence/result.dart';
import 'package:flutter_test/flutter_test.dart';

Result<String, MyException> getResult({required bool succeed}) {
  if (succeed) {
    return Success('Success');
  }

  return Failure(MyException('Failure'));
}

void main() {
  group('Result', () {
    late Result<String, MyException> result;

    group('if Success', () {
      setUp(() {
        result = getResult(succeed: true);
      });

      test('isSuccess should be true', () {
        expect(result.isSuccess, true);
      });

      test('isFailure should be false', () {
        expect(result.isFailure, false);
      });

      test('unwrap should return value', () {
        expect(result.unwrap(), 'Success');
      });

      test('match should call onSuccess', () {
        result.match(
          onSuccess: (value) {
            expect(value, 'Success');
          },
          onFailure: (value) {
            fail('onFailure should not be called');
          },
        );
      });

      test('match should return onSuccess value', () async {
        final ret = await result.match(
          onSuccess: (value) async {
            return 'Yes';
          },
          onFailure: (value) async {
            return 'No';
          },
        );
        expect(ret, 'Yes');
      });
    });

    group('if Failure', () {
      setUp(() {
        result = getResult(succeed: false);
      });

      test('isSuccess should be false', () {
        expect(result.isSuccess, false);
      });

      test('isFailure should be true', () {
        expect(result.isFailure, true);
      });

      test('unwrap should throw exception', () {
        expect(() => result.unwrap(), throwsA(isA<MyException>()));
      });

      test('match should call onFailure', () {
        result.match(
          onSuccess: (value) {
            fail('onSuccess should not be called');
          },
          onFailure: (value) {
            expect(value, isA<MyException>());
          },
        );
      });

      test('match should return onFailure value', () async {
        final ret = await result.match(
          onSuccess: (value) async {
            return 'Yes';
          },
          onFailure: (value) async {
            return 'No';
          },
        );
        expect(ret, 'No');
      });
    });
  });
}

class MyException implements Exception {
  final String message;

  MyException(this.message);
}
