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

import '../../diligence_config.dart';
import 'app_link.dart';
import 'keys.dart' as keys;

List<AppLink> _getLinks(DiligenceConfig config) {
  return [
    const AppLink(
      '/',
      'Home',
      keys.drawerLinkHome,
    ),
    const AppLink(
      '/tasks',
      'Tasks',
      keys.drawerLinkTasks,
    ),
    const AppLink(
      '/focus',
      'Focus',
      keys.drawerLinkFocus,
    ),
    if (config.showReviewPage) ...[
      const AppLink(
        '/review',
        'Review Link',
        keys.drawerLinkReview,
      ),
    ],
    const AppLink(
      '/settings',
      'Settings',
      keys.drawerLinkSettings,
    ),
  ];
}

class DiligenceDrawer extends StatelessWidget {
  final List<AppLink> _links;

  DiligenceDrawer({super.key, required DiligenceConfig config})
      : _links = _getLinks(config);

  @override
  Widget build(BuildContext context) => Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const DrawerHeader(
                child: Text('Diligence'),
              ),
              ..._links.map(
                (link) => ListTile(
                  key: link.key,
                  title: Text(link.title),
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed(link.path);
                  },
                ),
              ),
            ],
          ),
        ),
      );
}
