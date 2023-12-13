import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'diligence_container.dart';
import 'ui/screens/home/home_page.dart';
import 'ui/screens/review/review_page.dart';
import 'ui/screens/tasks_page.dart';
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
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          '/tasks': (context) => const TasksPage(),
          '/review': (context) => const ReviewPage(title: 'Diligence'),
        },
      ),
    );
  }
}
