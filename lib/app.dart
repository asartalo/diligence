import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'container.dart';
import 'ui/screens/review.dart';
import 'ui/theme.dart';

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
        initialRoute: '/review',
        routes: {
          '/review': (context) => const ReviewPage(title: 'Diligence'),
        },
      ),
    );
  }
}
