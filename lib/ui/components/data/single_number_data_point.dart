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

import '../../diligence_theme.dart';
import '../easy_card.dart';
import '../typography/data_title.dart';

class SingleNumberDataPoint extends StatelessWidget {
  final String title;
  final num number;
  final IconData icon;
  final Color color;

  const SingleNumberDataPoint({
    super.key,
    required this.title,
    required this.number,
    this.icon = Icons.check,
    this.color = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    final diligenceTheme = DiligenceTheme.fromTheme(Theme.of(context));
    final space = diligenceTheme.lengths.space;
    final textTheme = diligenceTheme.textTheme;

    return EasyCard(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0, space * .5, 0, space * 1.5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: 48.0,
                color: color,
              ),
              Text(
                "$number",
                style: textTheme.displayMedium,
              ),
              const SizedBox(height: 5.0),
              DataTitle(title),
            ],
          ),
        ),
      ],
    );
  }
}
