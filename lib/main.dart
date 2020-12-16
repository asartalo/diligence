import 'package:diligence/container.dart';
import 'package:flutter/material.dart';

import 'app.dart';

void main() async {
  runApp(DiligenceApp(await DiligenceContainer.start()));
}
