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

  @override
  final DateTime? deadlineAt;

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
    this.deadlineAt,
  })  : parentId = parentId ?? parent?.id,
        uid = uid ?? uuidGenerator.v4(),
        createdAt = createdAt ?? clock.now(),
        updatedAt = updatedAt ?? clock.now();

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
    DateTime? deadlineAt,
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
      updatedAt: updatedAt ?? clock.now(),
      deadlineAt: deadlineAt ?? this.deadlineAt,
    );
  }
}
