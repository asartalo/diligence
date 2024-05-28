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
import 'models/notices/error_notice.dart';
import 'services/diligent.dart';
import 'ui/diligence_theme.dart';
import 'ui/screens/focus/focus_screen.dart';
import 'ui/screens/home/home_screen.dart';
import 'ui/screens/review/review_screen.dart';
import 'ui/screens/settings/settings_screen.dart';
import 'ui/screens/tasks/tasks_screen.dart';
import 'utils/clock.dart';
import 'utils/uuidv4.dart';

final diligenceTheme = DiligenceTheme.createThemeData();

class DiligenceApp extends StatefulWidget {
  final DiligenceContainer container;

  const DiligenceApp(this.container, {super.key});

  @override
  State<DiligenceApp> createState() => _DiligenceAppState();
}

class _DiligenceAppState extends State<DiligenceApp> {
  late DiligenceContainer _container;
  late Key _key;
  late String _initialRoute;

  @override
  void initState() {
    super.initState();
    _key = Key(uuidv4());
    _container = widget.container;
    _initialRoute = '/';
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      key: _key,
      providers: _container.providers(),
      child: MaterialApp(
        title: 'Diligence',
        theme: diligenceTheme,
        initialRoute: _initialRoute,
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
          '/settings': (context) => SettingsScreen(
                config: Provider.of<DiligenceConfig>(context),
                onUpdateConfig: updateConfigHandler,
              ),
        },
      ),
    );
  }

  Future<void> updateConfigHandler(DiligenceConfig config) async {
    final result = await _container.configManager.saveConfig(config);
    await result.futureMatch(
      onSuccess: (_) async {
        final newContainer = await _container.reloadContainer();
        setState(() {
          _container = newContainer;
          _key = Key(uuidv4());
          _initialRoute = '/settings';
        });
      },
      onFailure: (e) async {
        await _container.di.noticeQueue.addNotice(
          ErrorNotice(
            createdAt: _container.di.clock.now(),
            title: 'Error saving config',
            details: e.message,
          ),
        );
      },
    );
  }
}
