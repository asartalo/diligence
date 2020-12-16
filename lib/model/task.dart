import 'package:meta/meta.dart';

class TaskRow {
  final int id;
  final int parentId;
  final int sortOrder;
  final String name;
  final bool done;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskRow._({
    this.id,
    this.parentId, // null means no parent or root task
    @required this.sortOrder,
    @required this.done,
    @required this.name,
    @required this.createdAt,
    @required this.updatedAt,
  });

  factory TaskRow({
    int id,
    int parentId,
    int sortOrder = 0,
    @required String name,
    bool done = false,
    DateTime createdAt,
    DateTime updatedAt,
  }) {
    final now = DateTime.now();
    return TaskRow._(
      id: id,
      parentId: parentId,
      done: done,
      name: name,
      sortOrder: sortOrder,
      createdAt: createdAt == null ? now : createdAt,
      updatedAt: updatedAt == null ? now : updatedAt,
    );
  }

  Map<String, dynamic> toSqliteMap() {
    return {
      'id': id,
      'parent_id': parentId,
      'sort_order': sortOrder,
      'name': name,
      'done': done ? 1 : 0,
      'created_at': createdAt.toString(),
      'updated_at': updatedAt.toString(),
    };
  }
}
