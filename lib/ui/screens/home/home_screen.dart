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
import 'package:intl/intl.dart';

import '../../components/clock_wrap.dart';
import '../../components/common_screen.dart';

class HomeScreen extends StatelessWidget {
  final timeFormat = DateFormat.jm();
  final dateFormat = DateFormat('EEEE, MMMM d, y');

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hourStyle = theme.textTheme.headlineLarge!.merge(
      const TextStyle(
        fontSize: 112.0,
        fontWeight: FontWeight.w200,
      ),
    );
    final welcomeStyle = theme.textTheme.headlineLarge!.merge(
      const TextStyle(
        fontSize: 64.0,
        fontWeight: FontWeight.w300,
      ),
    );
    final buttonStyle = FilledButton.styleFrom(
      minimumSize: const Size(64.0, 64.0),
    );

    return CommonScreen(
      title: 'Diligence',
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Center(
          child: ClockWrap(
            builder: (time) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Hello!', style: welcomeStyle),
                const SizedBox(height: 32.0),
                Text(
                  timeFormat.format(time),
                  style: hourStyle,
                ),
                Text(
                  dateFormat.format(time),
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 32.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/tasks');
                      },
                      style: buttonStyle,
                      child: const Text('Organize Tasks'),
                    ),
                    const SizedBox(width: 16.0),
                    FilledButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/focus');
                      },
                      style: buttonStyle,
                      child: const Text('Focus'),
                    ),
                  ],
                ),
                const SizedBox(height: 64.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
