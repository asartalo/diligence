import 'package:diligence/diligence_app.dart';
import 'package:diligence/diligence_container.dart';
import 'package:flutter/material.dart';

Future<DiligenceContainer> main() async {
  // Call the `main()` function of your app or call `runApp` with any widget you
  // are interested in testing.
  WidgetsFlutterBinding.ensureInitialized();
  final container = await DiligenceContainer.start(test: true);
  runApp(DiligenceApp(container));

  return container;
}
