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
      diligent.addTask(name: name, id: id);
    });
  }
}
