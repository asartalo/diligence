// Diligence - A Task Management App
//
// Copyright (C) 2024 Wayne Duran <asartalo@gmail.com>
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// this program. If not, see <https://www.gnu.org/licenses/>.

import 'package:clock/clock.dart';
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

  @override
  final DateTime? deadlineAt;

  ModifiedTask({
    this.parentId,
    this.doneAt,
    this.name = '',
    this.details,
    this.expanded = false,
    this.deadlineAt,
    required this.originalTask,
  }) : updatedAt = clock.now() {
    _checkModifications(
      originalTask,
      parentId: parentId,
      doneAt: doneAt,
      name: name,
      details: details,
      expanded: expanded,
      deadlineAt: deadlineAt,
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
    DateTime? deadlineAt,
  }) {
    return ModifiedTask(
      originalTask: originalTask,
      parentId: parentId ?? this.parentId,
      doneAt: normalizedDoneAt(done, doneAt),
      name: name ?? this.name,
      details: normalizedDetails(details),
      expanded: expanded ?? this.expanded,
      deadlineAt: deadlineAt ?? this.deadlineAt,
    );
  }

  void _checkModifications(
    Task original, {
    int? parentId,
    DateTime? doneAt,
    String? name,
    String? details,
    bool? expanded,
    DateTime? deadlineAt,
  }) {
    if (parentId != original.parentId) _modifiedFields.add('parentId');
    if (!sameTime(doneAt, original.doneAt)) _modifiedFields.add('doneAt');
    if (name != original.name) _modifiedFields.add('name');
    if (details != original.details) _modifiedFields.add('details');
    if (expanded != original.expanded) _modifiedFields.add('expanded');
    if (!sameTime(deadlineAt, original.deadlineAt)) {
      _modifiedFields.add('deadlineAt');
    }
  }

  Set<String> modifiedFields() {
    return _modifiedFields;
  }

  bool isModified(String field) {
    return modifiedFields().contains(field);
  }

  bool hasToggledDone() {
    return isModified('doneAt');
  }
}
