import '../model/objectbox.dart';
import '../model/task.dart';
import '../objectbox.g.dart';

typedef VoidCallback = void Function();
typedef TaskList = List<Task>;

class Diligent {
  final ObjectBox _objectBox;

  const Diligent({
    required ObjectBox objectbox,
  }) : _objectBox = objectbox;

  Task addTask({
    required String name,
    int id = 0,
    int? parentId,
    Task? parent,
  }) {
    return _objectBox.addTask(
      name: name,
      id: id,
      parentId: parentId,
      parent: parent,
    );
  }

  Task? findTask(int id) {
    return _objectBox.findTask(id);
  }

  void deleteTask(int id) {
    _objectBox.taskBox.remove(id);
  }

  void taskWriteTransaction(VoidCallback callback) {
    _objectBox.store.runInTransaction(TxMode.write, () => callback());
  }

  void taskReadTransaction(VoidCallback callback) {
    _objectBox.store.runInTransaction(TxMode.read, () => callback());
  }

  void _gatherDescendants(Task task, TaskList tasks) {
    tasks.add(task);
    if (task.childrenRel.isNotEmpty) {
      for (final child in task.children) {
        _gatherDescendants(child, tasks);
      }
    }
  }

  /// Returns a task and its descendants as an ordered list
  TaskList subtreeFlat(int id) {
    final current = findTask(id);
    final List<Task> tasks = [];
    if (current == null) {
      return tasks;
    }

    taskReadTransaction(() {
      _gatherDescendants(current, tasks);
    });
    return tasks;
  }
}
