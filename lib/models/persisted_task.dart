import 'package:flutter/foundation.dart' show immutable;
import 'modified_task.dart';
import 'task.dart';
import 'task_commons.dart';

@immutable
class PersistedTask with TaskCommons implements Task {
  @override
  final int id;

  @override
  final int? parentId;

  @override
  final DateTime? doneAt;

  @override
  bool get done => doneAt != null;

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

  const PersistedTask({
    this.id = 0,
    this.parentId,
    this.doneAt,
    this.name = '',
    this.details,
    this.expanded = false,
    required this.uid,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  ModifiedTask copyWith({
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
    return ModifiedTask(
      originalTask: this,
      parentId: parentId ?? this.parentId,
      doneAt: normalizedDoneAt(done, doneAt),
      name: name ?? this.name,
      details: normalizedDetails(details),
      expanded: expanded ?? this.expanded,
    );
  }
}
