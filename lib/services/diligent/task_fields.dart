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

import '../../models/task.dart';

enum TaskField {
  id,
  uid,
  name,
  details,
  parentId,
  doneAt,
  position,
  expanded,
  createdAt,
  updatedAt,
  deadlineAt;

  @override
  String toString() => this.name;
}

typedef TaskMappingFunc = Object? Function(Task task);

final Map<TaskField, TaskMappingFunc> _taskFieldMap = {
  TaskField.id: (Task task) => task.id.toString(),
  TaskField.uid: (Task task) => task.uid,
  TaskField.name: (Task task) => task.name,
  TaskField.details: (Task task) => task.details,
  TaskField.parentId: (Task task) => task.parentId,
  TaskField.doneAt: (Task task) => task.doneAt?.millisecondsSinceEpoch,
  TaskField.position: (Task task) => null,
  TaskField.expanded: (Task task) => task.expanded ? 1 : 0,
  TaskField.createdAt: (Task task) => task.createdAt.millisecondsSinceEpoch,
  TaskField.updatedAt: (Task task) => task.updatedAt.millisecondsSinceEpoch,
  TaskField.deadlineAt: (Task task) => task.deadlineAt?.millisecondsSinceEpoch,
};

final allTaskFields = [..._taskFieldMap.keys];

final _unmodifiableFields = {TaskField.id, TaskField.uid};

final _fieldsAfterNew = {TaskField.id, TaskField.position};

final newTaskFields =
    allTaskFields.where((field) => !_fieldsAfterNew.contains(field)).toList();

final _modifiableFields = allTaskFields
    .where((field) => !_unmodifiableFields.contains(field))
    .toList();

final modifiableNonPositionFields =
    _modifiableFields.where((field) => field != TaskField.position).toList();

String _prefixedField(TaskField field, {String? prefix}) {
  return prefix is String ? '$prefix.$field' : field.toString();
}

typedef Pass<T> = String Function(T item);

extension CommaIt<T> on Iterable<T> {
  String mapComma(Pass<T> pass) => map(pass).commas();

  String commas() => join(', ');
}

String commaFields(List<TaskField> fields, {String? prefix}) {
  return fields.mapComma((field) => _prefixedField(field, prefix: prefix));
}

final commaAllTaskFields = commaFields(allTaskFields);
final commaAllTaskFieldsPrefixed = commaFields(allTaskFields, prefix: 'tasks');

Object? _propFromTaskField(TaskField field, Task task) {
  final mapping = _taskFieldMap[field];

  if (mapping == null) {
    throw Exception('Unknown task field: $field');
  }

  return mapping(task);
}

List<Object?> propsFromTaskFields(List<TaskField> fields, Task task) {
  return fields.map((field) => _propFromTaskField(field, task)).toList();
}

String fieldValuePlaceholders(List<TaskField> fields, {String? prefix}) {
  return fields
      .mapComma((field) => '${_prefixedField(field, prefix: prefix)} = ?');
}

String questionMarks(int count) {
  return List.generate(count, (_) => '?').commas();
}
