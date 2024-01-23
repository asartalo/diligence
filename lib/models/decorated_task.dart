import 'task.dart';

abstract class DecoratedTask implements Task {
  Task get task;
}
