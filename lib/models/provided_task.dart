import 'dart:async';
import 'task.dart';
import 'task_commons.dart';

abstract class NodeProvider {
  FutureOr<List<Task>> getChildren(Task task);

  FutureOr<Task?> getParent(Task task);
}

class ProvidedTask with TaskCommons implements Task {
  @override
  final int id;

  @override
  final int? parentId;

  @override
  final bool done;

  @override
  final String name;

  @override
  final String? details;

  @override
  final String uid;

  @override
  final bool expanded;

  final NodeProvider _nodeProvider;

  @override
  FutureOr<List<Task>> get children => _nodeProvider.getChildren(this);

  @override
  FutureOr<Task?> get parent => _nodeProvider.getParent(this);

  ProvidedTask({
    this.id = 0,
    this.parentId,
    this.done = false,
    this.name = '',
    this.details,
    this.expanded = false,
    required this.uid,
    required NodeProvider nodeProvider,
  }) : _nodeProvider = nodeProvider;

  @override
  Task copyWith({
    int? id,
    int? parentId,
    bool? done,
    String? uid,
    String? name,
    String? details,
    bool? expanded,
  }) {
    return ProvidedTask(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      done: done ?? this.done,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      details: normalizedDetails(details),
      expanded: expanded ?? this.expanded,
      nodeProvider: _nodeProvider,
    );
  }
}
