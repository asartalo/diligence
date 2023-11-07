import '../objectbox.g.dart';
import 'config.dart';
import 'model/objectbox.dart';
import 'services/diligent.dart';

/// DIY Dependency-Injection Container
class DIContainer {
  final DiligenceConfig config;

  const DIContainer({
    required this.config,
  });

  Future<Store> get objectboxStore async => openStore();

  Future<ObjectBox> get objectbox async =>
      ObjectBox.create(await objectboxStore);

  Future<Diligent> get diligent async => Diligent(objectbox: await objectbox);
}
