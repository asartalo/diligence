import 'task_event.dart';

typedef TaskEventHandler<T extends TaskEvent> = Future<void> Function(T event);
typedef TaskEventHandlers<T extends TaskEvent> = List<TaskEventHandler<T>>;

class TaskEventRegistry {
  final _handlersByType = <Type, List<dynamic>>{};

  void register<T extends TaskEvent>(
    TaskEventHandler<T> handler,
  ) {
    final handlers = (_handlersByType[T] ?? []);
    handlers.add(handler);
    _handlersByType[T] = handlers;
  }

  Future<void> broadcast<T extends TaskEvent>(T event) async {
    final handlers = (_handlersByType[event.runtimeType] ?? []);
    for (final handle in handlers) {
      if (handle is TaskEventHandler<T>) {
        await handle(event);
      }
    }
  }
}
