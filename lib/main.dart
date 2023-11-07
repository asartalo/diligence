import 'package:flutter/material.dart';

import 'app.dart';
import 'diligence_container.dart';

Future<void> main() async {
  runApp(DiligenceApp(await DiligenceContainer.start()));
}
