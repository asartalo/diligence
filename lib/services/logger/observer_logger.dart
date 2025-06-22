import 'package:logger/logger.dart' as ologger;
import '../../utils/clock.dart';
import 'log_observable.dart';
import 'logger.dart';

class ObserverLogger extends BaseLogger {
  final LogObservable subject;

  ObserverLogger(this.subject, ologger.Logger oLogger, Clock clock)
    : super(subject.name, oLogger, clock) {
    subject.subscribe(this);
  }

  void stop() {
    subject.unsubscribe(this);
  }
}
