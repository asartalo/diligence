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

import '../../../services/diligent.dart';
import '../../components/common_screen.dart';

class SettingsScreen extends StatelessWidget {
  final Diligent diligent;
  const SettingsScreen({super.key, required this.diligent});

  @override
  Widget build(BuildContext context) {
    return CommonScreen(
      title: 'Settings',
      child: Container(
        margin: const EdgeInsets.fromLTRB(64.0, 48.0, 64.0, 0.0),
        child: ListView(
          children: [
            ListTile(
              title: const Text('Database Path'),
              subtitle: Text(diligent.path),
            ),
          ],
        ),
      ),
    );
  }
}
