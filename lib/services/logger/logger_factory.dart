import 'dart:io';

import 'package:logger/logger.dart' as ologger;
import '../../utils/clock.dart';
import 'log_observable.dart';
import 'logger.dart';
import 'observer_logger.dart';

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

  Logger createBasicLogger(String name) {
    return Logger.create(name, _logger, _clock);
  }

  ObserverLogger createObserverLogger(LogObservable subject) {
    return ObserverLogger(subject, _logger, _clock);
  }
}
