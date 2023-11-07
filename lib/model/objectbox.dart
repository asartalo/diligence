import '../objectbox.g.dart';

import 'task.dart';

class ObjectBox {
  late final Store store;
  late final Box<Task> taskBox;

  ObjectBox._create(this.store) {
    taskBox = store.box<Task>();
  }

  static Future<ObjectBox> create(Store? store) async {
    return ObjectBox._create(store ?? await openStore());
  }

  List<Task> tasks() {
    final builder = taskBox.query();
    // builder.order(Task_.index);
    return builder.build().find();
  }

  Task addTask({
    required String name,
    int id = 0,
    int? parentId,
    Task? parent,
  }) {
    final task = Task(name: name);
    if (parentId is int) {
      final parent = taskBox.get(parentId);
      task.parent = parent;
    } else if (parent is Task) {
      task.parent = parent;
    }
    final taskId = taskBox.put(task);
    task.id = taskId;
    return task;
  }

  Task? findTask(int id) {
    return taskBox.get(id);
  }
}
