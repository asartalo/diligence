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

import 'clock_wrap.dart';
import 'keys.dart' as keys;

AppBar appBar(BuildContext context, String title) {
  final theme = Theme.of(context);
  final titleStyle = theme.textTheme.titleLarge!.merge(
    TextStyle(
      color: theme.textTheme.bodyLarge!.color,
    ),
  );
  final dateFormat = DateFormat('EEEE, MMMM d, y').add_jm();

  return AppBar(
    leading: IconButton(
      key: keys.appBarMenuButton,
      icon: Icon(
        Icons.menu,
        color: theme.textTheme.bodyLarge!.color,
      ),
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
      tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
    ),
    actions: <Widget>[
      Padding(
        padding: const EdgeInsets.only(right: 20.0),
        child: Center(
          child: ClockWrap(
            builder: (time) => Text(
              dateFormat.format(time),
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ),
      ),
    ],
    title: Text(
      title,
      style: titleStyle,
    ),
    backgroundColor: theme.scaffoldBackgroundColor,
    shadowColor: Colors.transparent,
  );
}
