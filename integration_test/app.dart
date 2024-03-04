import 'package:diligence/diligence_app.dart';
import 'package:diligence/diligence_container.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  // Call the `main()` function of your app or call `runApp` with any widget you
  // are interested in testing.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(DiligenceApp(await DiligenceContainer.start(test: true)));
}
