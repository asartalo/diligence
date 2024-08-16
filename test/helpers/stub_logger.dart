import 'package:diligence/utils/logger.dart';

class StubLogger implements Logger {
  @override
  void debug(message, {Object? error}) {}

  @override
  void error(message, {Object? error}) {}

  @override
  void fatal(message, {Object? error}) {}

  @override
  void info(message, {Object? error}) {}

  @override
  void trace(message, {Object? error}) {}

  @override
  void warning(message, {Object? error}) {}
}
