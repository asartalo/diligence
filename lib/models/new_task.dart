import 'dart:async';
import 'task.dart';

class NewTask implements Task {
  @override
  final int id;

  @override
  final int? parentId;

  @override
  final bool done;

  @override
  final String name;

  @override
  FutureOr<List<Task>> get children => [];

  @override
  FutureOr<Task?> get parent => null;

  NewTask({
    this.id = 0,
    int? parentId,
    this.done = false,
    this.name = '',
    Task? parent,
  }) : parentId = parentId ?? parent?.id;

  @override
  Task copyWith({int? id, int? parentId, bool? done, String? name}) {
    return NewTask(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      done: done ?? this.done,
      name: name ?? this.name,
    );
  }
}
