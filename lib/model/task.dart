import 'package:objectbox/objectbox.dart';

@Entity()
class Task {
  int id;
  bool done;
  String name = '';

  final parentRel = ToOne<Task>();

  Task? get parent => parentRel.target;

  set parent(Task? newParent) {
    parentRel.target = newParent;
  }

  @Backlink('parentRel')
  final childrenRel = ToMany<Task>();

  List<Task> get children => childrenRel.toList();

  Task({
    this.id = 0,
    this.done = false,
    this.name = '',
  });
}
