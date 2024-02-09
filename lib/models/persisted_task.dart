import 'task.dart';
import 'task_commons.dart';

class PersistedTask with TaskCommons implements Task {
  @override
  final int id;

  @override
  final int? parentId;

  @override
  final DateTime? doneAt;

  @override
  bool get done => doneAt != null;

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

  PersistedTask({
    this.id = 0,
    this.parentId,
    this.doneAt,
    this.name = '',
    this.details,
    this.expanded = false,
    required this.uid,
    required this.createdAt,
    required this.updatedAt,
  });

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
  }) {
    return PersistedTask(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      doneAt: normalizedDoneAt(done, doneAt),
      uid: uid ?? this.uid,
      name: name ?? this.name,
      details: normalizedDetails(details),
      expanded: expanded ?? this.expanded,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
