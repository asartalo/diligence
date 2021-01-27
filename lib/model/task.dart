import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'task/task_defer_row.dart';
part 'task/task_row.dart';

@immutable
class Task extends Equatable {
  final int id;
  final int parentId;
  final int sortOrder;
  final bool done;
  final bool expanded;
  final String name;
  final String oldId;
  final String oldParentId;
  final DateTime doneAt;
  final DateTime primaryFocusedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object> get props => [
    id,
    parentId,
    sortOrder,
    done,
    expanded,
    name,
    done,
    oldId,
    oldParentId,
    doneAt,
    primaryFocusedAt,
    createdAt,
    updatedAt,
  ];

  const Task({
    this.id,
    this.parentId,
    this.done,
    this.expanded,
    this.sortOrder,
    this.name,
    this.oldId,
    this.oldParentId,
    this.doneAt,
    this.primaryFocusedAt,
    this.createdAt,
    this.updatedAt,
  });
}
