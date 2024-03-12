import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'diligence_container.dart';
import 'services/diligent.dart';
import 'ui/diligence_theme.dart';
import 'ui/screens/focus/focus_page.dart';
import 'ui/screens/home/home_page.dart';
import 'ui/screens/review/review_page.dart';
import 'ui/screens/tasks/tasks_page.dart';

final diligenceTheme = DiligenceTheme.createThemeData();

class DiligenceApp extends StatelessWidget {
  final DiligenceContainer container;

  const DiligenceApp(this.container, {super.key});

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
          '/tasks': (context) =>
              TasksPage(diligent: Provider.of<Diligent>(context)),
          '/focus': (context) =>
              FocusPage(diligent: Provider.of<Diligent>(context)),
          '/review': (context) => const ReviewPage(title: 'Diligence'),
        },
      ),
    );
  }

  Future<void> resetForTests() async {
    await container.diligent.clearDataForTests();
  }
}
