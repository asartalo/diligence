part of '../task.dart';

class TaskDeferRow extends Equatable {
  final int id;
  final int taskId;
  final double duration;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object> get props => [id, taskId, duration];

  TaskDeferRow._({
    this.id,
    @required this.taskId,
    @required this.duration,
    @required this.createdAt,
    @required this.updatedAt,
  });

  factory TaskDeferRow({
    int id,
    @required int taskId,
    @required double duration,
    DateTime createdAt,
    DateTime updatedAt,
  }) {
    final now = DateTime.now();
    return TaskDeferRow._(
      id: id,
      taskId: taskId,
      duration: duration,
      createdAt: createdAt == null ? now : createdAt,
      updatedAt: updatedAt == null ? now : updatedAt,
    );
  }

  Map<String, dynamic> toSqliteMap() {
    return {
      'id': id,
      'task_id': taskId,
      'duration': duration,
      'created_at': createdAt.toString(),
      'updated_at': updatedAt.toString(),
    };
  }
}
