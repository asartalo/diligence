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

import '../../../app_info.dart';
import '../../../diligence_config.dart';
import '../../components/common_screen.dart';
import 'settings_fields.dart';

class SettingsScreen extends StatelessWidget {
  final DiligenceConfig config;
  final void Function(DiligenceConfig config) onUpdateConfig;
  const SettingsScreen(
      {super.key, required this.config, required this.onUpdateConfig});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headingStyle = theme.textTheme.headlineLarge!.merge(
      const TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.w300,
      ),
    );

    return CommonScreen(
      title: 'Settings',
      child: Container(
        margin: const EdgeInsets.fromLTRB(64.0, 48.0, 64.0, 0.0),
        child: Column(
          children: [
            Text('Diligence', style: headingStyle),
            const SizedBox(height: 8.0),
            Text('Version: ${AppInfo.version.toString()}'),
            const SizedBox(height: 32.0),
            Expanded(
              child: SettingsFields(
                config: config,
                onUpdateConfig: onUpdateConfig,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
