import 'package:diligence/app.dart';
import 'package:diligence/container.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  // This line enables the extension
  // enableFlutterDriverExtension();

  // Call the `main()` function of your app or call `runApp` with any widget you
  // are interested in testing.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(DiligenceApp(await DiligenceContainer.start(test: true)));
}
