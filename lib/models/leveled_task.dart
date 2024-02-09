import 'decorated_task.dart';
import 'task.dart';

class LeveledTask implements Task, DecoratedTask {
  @override
  final Task task;
  final int level;
  final int childrenCount;
  final int position;

  const LeveledTask({
    required this.task,
    required this.level,
    required this.childrenCount,
    required this.position,
  });

  @override
  int get id => task.id;

  @override
  String get name => task.name;

  @override
  int? get parentId => task.parentId;

  @override
  bool get done => task.done;

  @override
  DateTime? get doneAt => task.doneAt;

  @override
  String? get details => task.details;

  @override
  bool get expanded => task.expanded;

  @override
  String get uid => task.uid;

  @override
  DateTime get createdAt => task.createdAt;

  @override
  DateTime get updatedAt => task.updatedAt;

  @override
  Task copyWith({
    int? id,
    String? name,
    int? parentId,
    bool? done,
    DateTime? doneAt,
    String? details,
    bool? expanded,
    String? uid,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LeveledTask(
      task: task.copyWith(
        id: id,
        name: name,
        parentId: parentId,
        done: done,
        doneAt: doneAt,
        details: details,
        expanded: expanded,
        uid: uid,
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
      level: level,
      childrenCount: childrenCount,
      position: position,
    );
  }

  @override
  Task markDone() => LeveledTask(
        task: task.markDone(),
        level: level,
        childrenCount: childrenCount,
        position: position,
      );

  @override
  Task markNotDone() => LeveledTask(
        task: task.markNotDone(),
        level: level,
        childrenCount: childrenCount,
        position: position,
      );
}
