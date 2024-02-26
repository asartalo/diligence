import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_test/flutter_test.dart';

@immutable
class ErrorMatcher<T extends Error> extends Matcher {
  final String message;

  const ErrorMatcher(this.message);

  @override
  Description describe(Description description) {
    return description.add('Error of type $T with message: $message');
  }

  @override
  bool matches(covariant dynamic item, Map<dynamic, dynamic> matchState) {
    return item is T && item.toString().contains(message);
  }

  @override
  Description describeMismatch(
    covariant dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    final described =
        super.describeMismatch(item, mismatchDescription, matchState, verbose);
    if (item is! T) {
      described.add('is not of type $T');
    }

    if (!item.toString().contains(message)) {
      described.add('does not contain message: $message');
    }
    return described;
  }
}

ErrorMatcher<T> matchesError<T extends Error>(String message) {
  return ErrorMatcher<T>(message);
}
