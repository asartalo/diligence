import 'package:meta/meta.dart';

import 'logger.dart';

@immutable
class LogObservable implements Logger {
  @override
  final String name;

  final Set<Logger> _loggers;

  LogObservable(this.name) : _loggers = <Logger>{};

  void subscribe(Logger logger) {
    _loggers.add(logger);
  }

  void unsubscribe(Logger logger) {
    _loggers.remove(logger);
  }

  void clear() {
    _loggers.clear();
  }

  @override
  void debug(message, {Object? error}) {
    for (var logger in _loggers) {
      logger.debug(message, error: error);
    }
  }

  @override
  void error(message, {Object? error}) {
    for (var logger in _loggers) {
      logger.error(message, error: error);
    }
  }

  @override
  void fatal(message, {Object? error}) {
    for (var logger in _loggers) {
      logger.fatal(message, error: error);
    }
  }

  @override
  void info(message, {Object? error}) {
    for (var logger in _loggers) {
      logger.info(message, error: error);
    }
  }

  @override
  void trace(message, {Object? error}) {
    for (var logger in _loggers) {
      logger.trace(message, error: error);
    }
  }

  @override
  void warning(message, {Object? error}) {
    for (var logger in _loggers) {
      logger.warning(message, error: error);
    }
  }
}
