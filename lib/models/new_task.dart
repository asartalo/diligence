import 'dart:async';
import 'package:uuid/uuid.dart';

import 'task.dart';
import 'task_commons.dart';

const uuidGenerator = Uuid();

class NewTask with TaskCommons implements Task {
  @override
  final int id;

  @override
  final int? parentId;

  @override
  final bool done;

  @override
  final String name;

  @override
  final String? details;

  @override
  final String uid;

  @override
  final bool expanded;

  @override
  FutureOr<List<Task>> get children => [];

  @override
  FutureOr<Task?> get parent => null;

  NewTask({
    this.id = 0,
    int? parentId,
    this.done = false,
    String? uid,
    this.name = '',
    this.details,
    this.expanded = false,
    Task? parent,
  })  : parentId = parentId ?? parent?.id,
        uid = uid ?? uuidGenerator.v4();

  @override
  Task copyWith({
    int? id,
    int? parentId,
    bool? done,
    String? uid,
    String? name,
    String? details,
    bool? expanded,
  }) {
    return NewTask(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      done: done ?? this.done,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      details: normalizedDetails(details),
      expanded: expanded ?? this.expanded,
    );
  }
}
