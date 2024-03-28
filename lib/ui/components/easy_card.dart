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

class EasyCard extends StatelessWidget {
  final List<Widget> children;
  final CrossAxisAlignment align;
  final double padding;

  const EasyCard({
    super.key,
    required this.children,
    this.align = alignCenter,
    this.padding = 20.0,
  });

  static const alignLeft = CrossAxisAlignment.start;
  static const alignCenter = CrossAxisAlignment.center;
  static const alignRight = CrossAxisAlignment.end;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: align,
          children: children,
        ),
      ),
    );
  }
}
