import 'dart:async';

abstract class Task {
  int get id;
  int? get parentId;
  bool get done;
  String get name;

  FutureOr<List<Task>> get children;

  FutureOr<Task?> get parent;

  Task copyWith({int? id, int? parentId, bool? done, String? name});
}
