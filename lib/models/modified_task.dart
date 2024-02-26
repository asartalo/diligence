import 'package:flutter/foundation.dart' show immutable;

import 'persisted_task.dart';
import 'task.dart';
import 'task_commons.dart';

bool sameTime(DateTime? a, DateTime? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  return a.isAtSameMomentAs(b);
}

@immutable
class ModifiedTask with TaskCommons implements Task {
  final PersistedTask originalTask;
  final _modifiedFields = <String>{};

  @override
  int get id => originalTask.id;

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
  String get uid => originalTask.uid;

  @override
  final bool expanded;

  @override
  DateTime get createdAt => originalTask.createdAt;

  @override
  final DateTime updatedAt;

  ModifiedTask({
    this.parentId,
    this.doneAt,
    this.name = '',
    this.details,
    this.expanded = false,
    required this.originalTask,
  }) : updatedAt = DateTime.now() {
    _checkModifications(
      originalTask,
      parentId: parentId,
      doneAt: doneAt,
      name: name,
      details: details,
      expanded: expanded,
    );
  }

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
      originalTask: originalTask,
      parentId: parentId ?? this.parentId,
      doneAt: normalizedDoneAt(done, doneAt),
      name: name ?? this.name,
      details: normalizedDetails(details),
      expanded: expanded ?? this.expanded,
    );
  }

  void _checkModifications(
    Task original, {
    int? parentId,
    DateTime? doneAt,
    String? name,
    String? details,
    bool? expanded,
  }) {
    if (parentId != original.parentId) _modifiedFields.add('parentId');
    if (!sameTime(doneAt, original.doneAt)) _modifiedFields.add('doneAt');
    if (name != original.name) _modifiedFields.add('name');
    if (details != original.details) _modifiedFields.add('details');
    if (expanded != original.expanded) _modifiedFields.add('expanded');
  }

  Set modifiedFields() {
    return _modifiedFields;
  }

  bool isModified(String field) {
    return modifiedFields().contains(field);
  }

  bool hasToggledDone() {
    return isModified('doneAt');
  }
}
