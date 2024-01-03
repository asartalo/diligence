import 'dart:async';
import 'task.dart';

abstract class NodeProvider {
  FutureOr<List<Task>> getChildren(Task task);

  FutureOr<Task?> getParent(Task task);
}

class ProvidedTask implements Task {
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
    required NodeProvider nodeProvider,
  }) : _nodeProvider = nodeProvider;

  @override
  Task copyWith({
    int? id,
    int? parentId,
    bool? done,
    String? name,
    String? details,
  }) {
    return ProvidedTask(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      done: done ?? this.done,
      name: name ?? this.name,
      details: details ?? this.details,
      nodeProvider: _nodeProvider,
    );
  }
}
