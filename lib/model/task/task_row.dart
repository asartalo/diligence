part of '../task.dart';

class TaskRow {
  final int? id;
  final int? parentId;
  final int sortOrder;
  final bool done;
  final bool expanded;
  final String name;
  final String? oldId;
  final String? oldParentId;
  final DateTime? doneAt;
  final DateTime? primaryFocusedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory TaskRow({
    int? id,
    int? parentId,
    int sortOrder = 0,
    bool expanded = false,
    required String name,
    bool done = false,
    String? oldId,
    String? oldParentId,
    DateTime? doneAt,
    DateTime? primaryFocusedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    return TaskRow._(
      id: id,
      parentId: parentId,
      done: done,
      expanded: expanded,
      name: name,
      oldId: oldId,
      oldParentId: oldParentId,
      sortOrder: sortOrder,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      doneAt: doneAt,
      primaryFocusedAt: primaryFocusedAt,
    );
  }

  const TaskRow._({
    this.id,
    this.parentId, // null means no parent or root task
    required this.sortOrder,
    required this.expanded,
    required this.name,
    required this.done,
    this.oldId,
    this.oldParentId,
    this.doneAt,
    this.primaryFocusedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toSqliteMap() {
    return {
      'id': id,
      'parent_id': parentId,
      'sort_order': sortOrder,
      'name': name,
      'done': done ? 1 : 0,
      'created_at': createdAt.toString(),
      'updated_at': updatedAt.toString(),
      'primary_focused_at': primaryFocusedAt.toString(),
      'done_at': doneAt.toString(),
    };
  }
}
