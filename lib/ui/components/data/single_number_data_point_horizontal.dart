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

class SingleNumberDataPointHorizontal extends StatelessWidget {
  final String title;
  final String caption;
  final num number;

  const SingleNumberDataPointHorizontal({
    super.key,
    required this.title,
    required this.caption,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    final diligenceTheme = DiligenceTheme.fromTheme(Theme.of(context));
    final textTheme = diligenceTheme.textTheme;

    return EasyCard(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DataTitle(title),
                const SizedBox(height: 10.0),
                Text(caption, style: textTheme.bodySmall),
              ],
            ),
            Text("$number", style: textTheme.displaySmall),
          ],
        ),
      ],
    );
  }
}
