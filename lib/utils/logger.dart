import 'dart:io';

import 'package:logger/logger.dart' as ologger;

import 'clock.dart';

enum LogLevel {
  all,
  trace,
  debug,
  info,
  warning,
  error,
  fatal,
  off;

  String label() {
    return _levelLabel[this]!;
  }

  static LogLevel fromName(String name, LogLevel defaultLevel) {
    final valueMap = LogLevel.values.asNameMap();
    LogLevel? level = valueMap[name];
    if (level == null) {
      return defaultLevel;
    }
    return level;
  }

  @override
  String toString() {
    return label().toLowerCase();
  }
}

Map<LogLevel, ologger.Level> _levelMapping = {
  LogLevel.all: ologger.Level.all,
  LogLevel.trace: ologger.Level.trace,
  LogLevel.debug: ologger.Level.debug,
  LogLevel.info: ologger.Level.info,
  LogLevel.warning: ologger.Level.warning,
  LogLevel.error: ologger.Level.error,
  LogLevel.fatal: ologger.Level.fatal,
  LogLevel.off: ologger.Level.off,
};

Map<LogLevel, String> _levelLabel = {
  LogLevel.all: 'All',
  LogLevel.trace: 'Trace',
  LogLevel.debug: 'Debug',
  LogLevel.info: 'Info',
  LogLevel.warning: 'Warning',
  LogLevel.error: 'Error',
  LogLevel.fatal: 'Fatal',
  LogLevel.off: 'Off',
};

class LoggerFactory {
  final Clock _clock;
  final ologger.Logger _logger;

  LoggerFactory(this._clock, this._logger);

  static LoggerFactory create(Clock clock, {String logFile = ''}) {
    final logOutput = logFile.isNotEmpty
        ? ologger.MultiOutput([
            ologger.ConsoleOutput(),
            ologger.FileOutput(file: File(logFile)),
          ])
        : null;
    return LoggerFactory(
      clock,
      ologger.Logger(
        printer: ologger.HybridPrinter(
          ologger.SimplePrinter(),
          error: ologger.PrettyPrinter(),
          fatal: ologger.PrettyPrinter(),
        ),
        output: logOutput,
      ),
    );
  }

  Logger createLogger(String name, {String logFile = ''}) {
    return Logger.create(name, _logger, _clock);
  }
}

abstract class Logger {
  void trace(dynamic message, {Object? error}) {}

  void debug(dynamic message, {Object? error}) {}

  void info(dynamic message, {Object? error}) {}

  void warning(dynamic message, {Object? error}) {}

  void error(dynamic message, {Object? error}) {}

  void fatal(dynamic message, {Object? error}) {}

  static void setLevel(LogLevel level) {
    ologger.Logger.level = _levelMapping[level]!;
  }

  static Logger create(
      String name, ologger.Logger originalLogger, Clock clock) {
    return _Logger(name, originalLogger, clock);
  }
}

class _Logger extends Logger {
  final ologger.Logger _oLogger;
  final String name;
  final Clock _clock;

  _Logger(this.name, this._oLogger, this._clock);

  String wrapMessage(dynamic message) {
    return '$name: $message';
  }

  @override
  void trace(dynamic message, {Object? error}) {
    _oLogger.t(
      wrapMessage(message),
      time: _clock.now(),
      error: error,
    );
  }

  @override
  void debug(dynamic message, {Object? error}) {
    _oLogger.d(
      wrapMessage(message),
      time: _clock.now(),
      error: error,
    );
  }

  @override
  void info(dynamic message, {Object? error}) {
    _oLogger.i(
      wrapMessage(message),
      time: _clock.now(),
      error: error,
    );
  }

  @override
  void warning(dynamic message, {Object? error}) {
    _oLogger.w(
      wrapMessage(message),
      time: _clock.now(),
      error: error,
    );
  }

  @override
  void error(dynamic message, {Object? error}) {
    _oLogger.e(
      wrapMessage(message),
      time: _clock.now(),
      error: error,
    );
  }

  @override
  void fatal(dynamic message, {Object? error}) {
    _oLogger.e(
      wrapMessage(message),
      time: _clock.now(),
      error: error,
    );
  }
}
