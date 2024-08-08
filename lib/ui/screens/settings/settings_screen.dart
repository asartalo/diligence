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

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

import '../../../app_info.dart';
import '../../../diligence_config.dart';
import '../../../utils/logger.dart';
import '../../components/common_screen.dart';

class SettingsScreen extends StatelessWidget {
  final DiligenceConfig config;
  final Logger logger;

  final void Function(DiligenceConfig config) onUpdateConfig;
  const SettingsScreen({
    super.key,
    required this.config,
    required this.onUpdateConfig,
    required this.logger,
  });

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
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(64.0, 48.0, 64.0, 0.0),
              child: Column(
                children: [
                  Text('Diligence', style: headingStyle),
                  const SizedBox(height: 8.0),
                  Text('Version: ${AppInfo.version.toString()}'),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(64.0, 32.0, 64.0, 0.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(settingsFields()),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> settingsFields() {
    return [
      ListTile(
        title: const Text('Database Path'),
        subtitle: SelectableText(config.dbPath),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () async {
            logger.info('Edit database path');
            logger.debug('Yeah!');
            final fileName = basename(config.dbPath);
            final containingDirectory = dirname(config.dbPath);
            final result = await getSaveLocation(
              suggestedName: fileName,
              initialDirectory: containingDirectory,
            );

            if (result != null) {
              onUpdateConfig(config.copyWith(
                dbPath: result.path,
              ));
            }
          },
        ),
      ),
      const Padding(
        padding: EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 8.0),
        child: Text('Developer Settings', style: TextStyle(fontSize: 24.0)),
      ),
      ListTile(
        title: const Text('Log Level'),
        subtitle: DropdownButton<LogLevel>(
          value: config.logLevel,
          onChanged: (level) {
            onUpdateConfig(config.copyWith(
              logLevel: level,
            ));
            if (level != null) {
              logger.info('Log level set to ${level.name}');
            } else {
              logger.info('Log level set to null');
            }
          },
          items: LogLevel.values
              .map((level) => DropdownMenuItem(
                    value: level,
                    child: Text(level.label()),
                  ))
              .toList(),
        ),
      ),
      SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              logger.trace('Trace');
              logger.debug('Debug');
              logger.info('Info');
              logger.warning('Warning');
              logger.error('Error');
              logger.fatal('Fatal!');
            },
            child: const Text('Test Logs'),
          )),
    ];
  }
}
