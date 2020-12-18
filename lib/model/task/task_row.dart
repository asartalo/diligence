part of '../task.dart';

class TaskRow extends Equatable {
  final int id;
  final int parentId;
  final int sortOrder;
  final String name;
  final bool done;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime doneAt;
  final DateTime primaryFocusedAt;

  @override
  List<Object> get props => [
        id,
        parentId,
        sortOrder,
        name,
        done,
        createdAt,
        updatedAt,
        doneAt,
        primaryFocusedAt,
      ];

  factory TaskRow({
    int id,
    int parentId,
    int sortOrder = 0,
    @required String name,
    bool done = false,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime doneAt,
    DateTime primaryFocusedAt,
  }) {
    final now = DateTime.now();
    return TaskRow._(
      id: id,
      parentId: parentId,
      done: done,
      name: name,
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
    @required this.sortOrder,
    @required this.done,
    @required this.name,
    @required this.createdAt,
    @required this.updatedAt,
    this.doneAt,
    this.primaryFocusedAt,
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
