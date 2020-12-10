import 'package:diligence/ui/theme.dart';
import 'package:flutter/material.dart';

import './ui/screens/review.dart';

void main() {
  runApp(MyApp());
}

var diligenceTheme = DiligenceTheme.createThemeData();

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diligence',
      theme: diligenceTheme,
      home: ReviewPage(title: 'Diligence'),
    );
  }
}
