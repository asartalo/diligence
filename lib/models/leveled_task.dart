import 'dart:async';

import 'decorated_task.dart';
import 'task.dart';

class LeveledTask implements Task, DecoratedTask {
  @override
  final Task task;
  final int level;

  const LeveledTask({
    required this.task,
    required this.level,
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
  String? get details => task.details;

  @override
  bool get expanded => task.expanded;

  @override
  String get uid => task.uid;

  @override
  FutureOr<List<Task>> get children => task.children;

  @override
  FutureOr<Task?> get parent => task.parent;

  @override
  Task copyWith({
    int? id,
    String? name,
    int? parentId,
    bool? done,
    String? details,
    bool? expanded,
    String? uid,
  }) {
    return LeveledTask(
      task: task.copyWith(
        id: id,
        name: name,
        parentId: parentId,
        done: done,
        details: details,
        expanded: expanded,
        uid: uid,
      ),
      level: level,
    );
  }
}
