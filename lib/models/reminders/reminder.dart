import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class Reminder extends Equatable {
  final int taskId;
  final DateTime remindAt;
  final bool dismissed;

  const Reminder({
    required this.taskId,
    required this.remindAt,
    this.dismissed = false,
  });

  Reminder copyWith({
    int? taskId,
    DateTime? remindAt,
    bool? dismissed,
  }) {
    return Reminder(
      taskId: taskId ?? this.taskId,
      remindAt: remindAt ?? this.remindAt,
      dismissed: dismissed ?? this.dismissed,
    );
  }

  Reminder dismiss() => copyWith(dismissed: true);

  @override
  List<Object?> get props => [
        taskId,
        remindAt.millisecondsSinceEpoch,
        dismissed,
      ];

  @override
  String toString() {
    return 'Reminder $taskId $remindAt dismissed: $dismissed';
  }
}
