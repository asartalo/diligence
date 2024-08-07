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

import 'task.dart';

mixin TaskCommons implements Task {
  String? normalizedDetails(String? str) {
    if (str is String && str.trim().isEmpty) {
      return null;
    }

    return str ?? details;
  }

  DateTime? normalizedDoneAt(DateTime now, bool? doneIntent, DateTime? dt) {
    if (doneIntent == null) {
      if (dt == null) {
        return doneAt;
      }
      if (dt != doneAt) {
        return dt;
      }
    }

    if (doneIntent == done) {
      if (dt is DateTime && dt != doneAt) {
        return dt;
      }

      return doneAt;
    }

    if (doneIntent == true) {
      return now;
    }

    return null;
  }

  @override
  Task markDone(DateTime now) {
    return copyWith(done: true, now: now);
  }

  @override
  Task markNotDone(DateTime now) {
    return copyWith(done: false, now: now);
  }

  @override
  void validate() {
    if (name.isEmpty) {
      throw ArgumentError('Task name must not be empty.');
    }
  }

  @override
  String toString() {
    return 'Task(id: $id, name: $name, parentId: $parentId, done: $done, doneAt: $doneAt, details: $details, expanded: $expanded, uid: $uid, createdAt: $createdAt, updatedAt: $updatedAt, deadlineAt: $deadlineAt)';
  }
}
