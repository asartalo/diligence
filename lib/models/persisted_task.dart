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

  @override
  final DateTime? deadlineAt;

  const PersistedTask({
    this.id = 0,
    this.parentId,
    this.doneAt,
    this.name = '',
    this.details,
    this.expanded = false,
    this.deadlineAt,
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
    DateTime? deadlineAt,
    required DateTime now,
  }) {
    return ModifiedTask(
      now: now,
      originalTask: this,
      parentId: parentId ?? this.parentId,
      doneAt: normalizedDoneAt(now, done, doneAt),
      name: name ?? this.name,
      details: normalizedDetails(details),
      expanded: expanded ?? this.expanded,
      deadlineAt: deadlineAt ?? this.deadlineAt,
    );
  }
}
