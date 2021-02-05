part of '../task.dart';

class TaskDeferRow extends Equatable {
  final int id;
  final int taskId;
  final double duration;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object> get props => [id, taskId, duration];

  factory TaskDeferRow({
    int? id,
    required int taskId,
    required double duration,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    return TaskDeferRow._(
      id: id ?? 0,
      taskId: taskId,
      duration: duration,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  const TaskDeferRow._({
    required this.id,
    required this.taskId,
    required this.duration,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toSqliteMap() {
    return {
      'id': id == 0 ? null : id,
      'task_id': taskId,
      'duration': duration,
      'created_at': createdAt.toString(),
      'updated_at': updatedAt.toString(),
    };
  }
}
