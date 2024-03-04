import 'package:flutter/material.dart';

import 'diligence_app.dart';
import 'diligence_container.dart';

Future<void> main() async {
  runApp(DiligenceApp(await DiligenceContainer.start()));
}
