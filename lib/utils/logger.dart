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

class Logger {
  final ologger.Logger _oLogger;
  final String name;
  final Clock _clock;

  Logger(this.name, ologger.Logger ologger, Clock clock)
      : _oLogger = ologger,
        _clock = clock;

  static void setLevel(LogLevel level) {
    ologger.Logger.level = _levelMapping[level]!;
  }

  static Logger create(String name, Clock clock) {
    return Logger(
      name,
      ologger.Logger(
        printer: ologger.HybridPrinter(
          ologger.SimplePrinter(),
          error: ologger.PrettyPrinter(),
          fatal: ologger.PrettyPrinter(),
        ),
        output: null,
      ),
      clock,
    );
  }

  String wrapMessage(dynamic message) {
    return '$name: $message';
  }

  void trace(dynamic message, {Object? error}) {
    _oLogger.t(
      wrapMessage(message),
      time: _clock.now(),
      error: error,
    );
  }

  void debug(dynamic message, {Object? error}) {
    _oLogger.d(
      wrapMessage(message),
      time: _clock.now(),
      error: error,
    );
  }

  void info(dynamic message, {Object? error}) {
    _oLogger.i(
      wrapMessage(message),
      time: _clock.now(),
      error: error,
    );
  }

  void warning(dynamic message, {Object? error}) {
    _oLogger.w(
      wrapMessage(message),
      time: _clock.now(),
      error: error,
    );
  }

  void error(dynamic message, {Object? error}) {
    _oLogger.e(
      wrapMessage(message),
      time: _clock.now(),
      error: error,
    );
  }

  void fatal(dynamic message, {Object? error}) {
    _oLogger.e(
      wrapMessage(message),
      time: _clock.now(),
      error: error,
    );
  }
}
