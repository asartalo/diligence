import 'package:diligence/ui/screens/review.dart';
import 'package:diligence/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'container.dart';

final diligenceTheme = DiligenceTheme.createThemeData();

class DiligenceApp extends StatelessWidget {
  final DiligenceContainer container;

  const DiligenceApp(this.container);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: container.providers(),
      child: MaterialApp(
        title: 'Diligence',
        theme: diligenceTheme,
        home: const ReviewPage(title: 'Diligence'),
      ),
    );
  }
}
