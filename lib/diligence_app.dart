// Diligence - A Task Management App
//
// Copyright (C) 2024 Wayne Duran <asartalo@gmail.com>
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// this program. If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'diligence_config.dart';
import 'diligence_container.dart';
import 'services/diligent.dart';
import 'ui/diligence_theme.dart';
import 'ui/screens/focus/focus_screen.dart';
import 'ui/screens/home/home_screen.dart';
import 'ui/screens/review/review_screen.dart';
import 'ui/screens/settings/settings_screen.dart';
import 'ui/screens/tasks/tasks_screen.dart';
import 'utils/clock.dart';

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
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
        ],
        routes: {
          '/': (context) => HomeScreen(clock: Provider.of<Clock>(context)),
          '/tasks': (context) => TasksScreen(
                diligent: Provider.of<Diligent>(context),
                clock: Provider.of<Clock>(context),
              ),
          '/focus': (context) => FocusScreen(
                diligent: Provider.of<Diligent>(context),
                clock: Provider.of<Clock>(context),
              ),
          '/review': (context) => const ReviewScreen(title: 'Diligence'),
          '/settings': (context) =>
              SettingsScreen(config: Provider.of<DiligenceConfig>(context)),
        },
      ),
    );
  }
}
