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

abstract class Task {
  int get id;
  String get name;
  int? get parentId;
  bool get done;
  DateTime? get doneAt;
  String? get details;
  bool get expanded;
  String get uid;
  DateTime get createdAt;
  DateTime get updatedAt;
  DateTime? get deadlineAt;

  Task copyWith({
    int? id,
    String? name,
    int? parentId,
    bool? done,
    DateTime? doneAt,
    String? details,
    bool? expanded,
    String? uid,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deadlineAt,
  });

  Task markDone();

  Task markNotDone();

  void validate();
}
