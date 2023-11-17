import 'package:diligence/model/new_task.dart';
import 'package:diligence/services/diligent.dart';

const roots = {
  'Main': 1,
  'Archive': 2,
};

const mainRootChildren = [
  'Life Goals',
  'Work',
  'Projects',
  'Everyday',
];

class DataSeeder {
  final Diligent diligent;

  DataSeeder(this.diligent);

  void createRoots() {
    roots.forEach((name, id) {
      diligent.addTask(NewTask(name: name, id: id));
    });
  }
}
