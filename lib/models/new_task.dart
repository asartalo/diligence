import 'package:flutter/foundation.dart' show immutable;
import 'package:uuid/uuid.dart';

import 'task.dart';
import 'task_commons.dart';

const uuidGenerator = Uuid();

@immutable
class NewTask with TaskCommons implements Task {
  @override
  final int id;

  @override
  final int? parentId;

  @override
  bool get done => doneAt != null;

  @override
  final DateTime? doneAt;

  @override
  final String name;

  @override
  final String? details;

  @override
  final String uid;

  @override
  final bool expanded;

  @override
  final DateTime createdAt;

  @override
  final DateTime updatedAt;

  NewTask({
    this.id = 0,
    int? parentId,
    this.doneAt,
    String? uid,
    this.name = '',
    this.details,
    this.expanded = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    Task? parent,
  })  : parentId = parentId ?? parent?.id,
        uid = uid ?? uuidGenerator.v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  @override
  Task copyWith({
    int? id,
    int? parentId,
    bool? done,
    DateTime? doneAt,
    String? uid,
    String? name,
    String? details,
    bool? expanded,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NewTask(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      doneAt: normalizedDoneAt(done, doneAt),
      uid: uid ?? this.uid,
      name: name ?? this.name,
      details: normalizedDetails(details),
      expanded: expanded ?? this.expanded,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
