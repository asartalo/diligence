import 'dart:async';

abstract class Task {
  int get id;
  String get name;
  int? get parentId;
  bool get done;
  String? get details;
  bool get expanded;
  String get uid;

  FutureOr<List<Task>> get children;

  FutureOr<Task?> get parent;

  Task copyWith({
    int? id,
    String? name,
    int? parentId,
    bool? done,
    String? details,
    bool? expanded,
    String? uid,
  });
}
