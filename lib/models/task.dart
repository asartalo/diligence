abstract class Task {
  int get id;
  String get name;
  int? get parentId;
  bool get done;
  DateTime? get doneAt;
  String? get details;
  bool get expanded;
  String get uid;
  DateTime get createdAt;
  DateTime get updatedAt;

  Task copyWith({
    int? id,
    String? name,
    int? parentId,
    bool? done,
    DateTime? doneAt,
    String? details,
    bool? expanded,
    String? uid,
    DateTime? createdAt,
    DateTime? updatedAt,
  });

  Task markDone();

  Task markNotDone();
}
